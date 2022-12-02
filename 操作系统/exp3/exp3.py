import wcwidth
from tabulate import tabulate

cpu_time = 0
page_size = 1
record = []

class page:
    def __init__(self, pn):
        self.page_num = pn
        self.pframe_num = -1
        self.timestamp = -1
        self.counter = 0
        self.priority = 0

    def __str__(self):
        return "Page {}: {}=\n".format(self.page_num, self.pframe_num)

    def __lt__(self, other):
        return self.priority < other.priority


class page_frame:
    def __init__(self, pfn):
        self.pframe_num = pfn
        self.page_num = -1

    def __str__(self):
        return "Frame {}->{}\n".format(self.pframe_num, self.page_num)


def initialize(total_pf, total_vp):
    """
    :param total_pf: 要初始化的页面数量
    :param total_vp: 要初始化的页的数量
    :return: 返回页的列表和页面的列表
    """
    page_list = [page(i) for i in range(total_vp)]
    pframe_list = [page_frame(i) for i in range(total_pf)]

    return page_list, pframe_list


# 先进先出淘汰策略
def FIFO(vaddr, page_list, busyf):
    global record
    # 将busy中的第一个页面换出
    tmp = busyf[0]
    page_list[tmp.page_num].pframe_num = -1
    # 将需要的页换入
    page_list[vaddr].pframe_num = tmp.pframe_num
    page_list[vaddr].timestamp = cpu_time
    page_list[vaddr].counter = 1
    # 为了维持队列，将该元素重新插到队尾
    del busyf[0]
    tmp.page_num = vaddr
    busyf.append(tmp)

    return 1


# 最近最久未使用淘汰策略
def LRU(vaddr, page_list, busyf):
    earliest = (0, page_list[busyf[0].page_num].timestamp)
    # 在所有页面中遍历找出使用时间戳最早的，将其换出
    for idx, i in enumerate(busyf):
        page = page_list[i.page_num]
        if page.timestamp < earliest[1]:
            earliest = (idx, page.timestamp)
    page_list[busyf[0].page_num].pframe_num = -1
    # 将需要的页换入
    page_list[vaddr].pframe_num = busyf[0].pframe_num
    page_list[vaddr].timestamp = cpu_time
    page_list[vaddr].counter = 1

    return 1

# 最近最少使用淘汰算法
def LFU(vaddr, page_list, busyf):
    least_use = (0, page_list[busyf[0].page_num].counter)
    # 在所有页中遍历找出使用次数最少的，将其换出
    for idx, i in enumerate(busyf):
        page = page_list[i.page_num]
        if page.counter < least_use[1]:
            least_use = (idx, page.counter)

    page_list[busyf[least_use[0]].page_num].pframe_num = -1
    # 将需要的页换入
    page_list[vaddr].pframe_num = busyf[least_use[0]].pframe_num
    page_list[vaddr].timestamp = cpu_time
    page_list[vaddr].counter += 1
    busyf[least_use[0]].page_num = vaddr


# 最近没有使用的淘汰策略，此处具体实现使用CLOCK算法
def NUR(vaddr, page_list, busyf):
    global NUR_pt
    if "NUR_pt" not in globals():
        NUR_pt = 0
    flag = True
    # 标志位仍利用counter字段
    while flag:
        # 当前检查的页面对应的页
        page = page_list[busyf[NUR_pt].page_num]
        # 若未访问过，就换出
        if page.counter == 0:
            page_list[busyf[NUR_pt].page_num].pframe_num = -1
            flag = False
            break
        else:
            # 访问过，将访问位置零，继续循环查找
            page.counter = 0
            NUR_pt = (NUR_pt + 1) % len(busyf)
            continue

    # 换入需要的页
    page_list[vaddr].pframe_num = busyf[NUR_pt].pframe_num
    page_list[vaddr].timestamp = cpu_time
    page_list[vaddr].counter = 1
    busyf[NUR_pt].page_num = vaddr
    # 换入后指针后移一个
    NUR_pt = (NUR_pt + 1) % len(busyf)


# 用于输出展示分配替换的表格
def display_table(visit_seq, dispatch_state, pframe_num):
    header = [" "] + visit_seq
    data = [[" " for i in range(len(header))] for j in range(pframe_num)]
    for i in range(len(visit_seq)):
        for idx, j in enumerate(dispatch_state[i]):
            data[idx][i+1] = j
    for i in range(pframe_num):
        data[i][0] = "页面{}".format(str(i))

    print(tabulate(data, headers=header, tablefmt="grid"))


def main(replace_algorithm, visit_seq):
    global page_size
    # 要求用户输入页面数量与页数量
    total_pf = int(input("设置页面数量："))
    total_vp = max(visit_seq) + 1
    page_size = int(input("设置页面大小："))

    global cpu_time
    global record
    dismiss = 0
    visit_cnt = 0

    # 初始化后，页面都是空闲的
    # freef、busyf分别为空闲页面链表和正在使用的页面链表，下标为0视为队头
    page_list, freef = initialize(total_pf, total_vp)
    busyf = []
    # 逐个访问地址序列
    for addr in visit_seq:
        # 计算得到虚页号
        vaddr = addr // page_size
        # 页访问范围的控制
        if vaddr >= total_vp:
            print("地址{}超出页的范围，跳过".format)
            continue
        visit_cnt += 1
        # 要访问的页对应的页面在内存中，直接访问即可
        if page_list[vaddr].pframe_num >= 0:
            # 更新访问时间及访问次数
            page_list[vaddr].timestamp = cpu_time
            page_list[vaddr].counter += 1
        else:
            # 要访问的页对应的页面不在内存中，而在外存中，此时需要换入，即产生缺页中断
            dismiss += 1
            # 内存中仍有空闲页面，直接使用即可
            if len(freef) > 0:
                # 访问之
                page_list[vaddr].pframe_num = freef[0].pframe_num
                page_list[vaddr].timestamp = cpu_time
                page_list[vaddr].counter = 1
                freef[0].page_num = vaddr
                # 将该页面加入busy
                busyf.append(freef[0])
                del freef[0]
            else:
                # 内存中没有空闲页面了，调用置换算法完成换入换出操作
                replace_algorithm(vaddr, page_list, busyf)
        cpu_time += 1
        # 记录每次分配完成后的页面情况
        record.append(tuple([i.page_num for i in busyf]))
    display_table(visit_seq, record, total_pf)
    print("缺页率为：{}%".format(round(dismiss*100 / visit_cnt, 2)))


if __name__ == "__main__":
    visit_list = input("请输入访问序列（以空格分隔）\n")
    visit_list = visit_list.split()
    visit_list = [int(i) for i in visit_list]
    main(NUR, visit_list)
