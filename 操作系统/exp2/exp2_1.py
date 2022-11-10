from typing import List
from queue import PriorityQueue

global INTERACTABLE
INTERACTABLE = True

class PCB:
    state_create = "CREATED"
    state_running = "RUNNING"
    state_ready = "READY"
    state_waiting = "WAITING"
    state_done = "TERMINATED"

    def __init__(self, pid, total_time, create_time, priority=5):
        self.pid = pid
        self.state = PCB.state_create
        # 需要运行的总时间
        self.total_time = total_time
        # 已经运行的CPU时间
        self.cpu_time = 0
        # 创建时间
        self.create_time = create_time
        # 优先级（数字越大越优先）
        self.priority = priority

    # pid相等就认为是相同的进程
    def __eq__(self, other):
        return self.pid == other.pid

    def __lt__(self, other):
        # 优先级数字大的越优先（本身越小）
        if self.priority > other.priority:
            return True
        # 优先级相等时，pid小的更优先
        if self.priority == other.priority and self.pid < other.pid:
            return True
        return False

    def __str__(self):
        template = "{:<8}{:<15}{:<25}{:<8}"
        return template.format(self.pid, self.state, str(self.cpu_time) + '/' + str(self.total_time), self.priority)


class PCBLinkedList:
    def __init__(self):
        # 列表前面作为头，后面作为尾
        self.list = []
        # 用于存放已完成的PCB（即state_done状态的PCB）
        self.trash = []
        self.pids = set()

    def __iter__(self):
        return iter(self.list)

    # PCB表中加入一个进程
    def add_one(self, item: PCB):
        if item.pid in self.pids:
            print("PID冲突，请换一个PID")
            return
        self.list.append(item)
        self.pids.add(item.pid)

    # PCB表中加入多个进程
    def add_many(self, items: List[PCB]):
        for i in items:
            if i.pid in self.pids:
                print("PID{}冲突，请换一个PID".format(i.pid))
                continue
            self.list.append(i)
            self.pids.add(i.pid)

    # 测试PID是否存在
    def pid_exist(self, pid):
        return pid in self.pids

    # PCB表中删除一个进程
    def delete_one(self, pid):
        idx = -1
        for k, i in enumerate(self.list):
            if i.pid == pid:
                idx = k
                break

        if idx < 0:
            print("PID{}不存在，忽略".format(pid))
        else:
            item = self.list[idx]
            self.trash.append(item)
            self.pids.remove(pid)
            del self.list[idx]

    # 检查PCB表是否为空
    def is_empty(self):
        return True if len(self.list) == 0 else False

    # 获取PCB表的头部进程
    def get_head(self):
        if len(self.list) == 0:
            raise IndexError("当前PCB链表为空")
        return self.list[0]

    # 获取PCB表的尾部进程
    def get_tail(self):
        if len(self.list) == 0:
            raise IndexError("当前PCB链表为空")
        return self.list[-1]
    
    """
    # 删除PCB表的头部进程
    def remove_head(self):
        if len(self.list) == 0:
            raise IndexError("当前PCB链表为空")
        del self.list[0]

    # 删除PCB表的尾部进程
    def remove_tail(self):
        if len(self.list) == 0:
            raise IndexError("当前PCB链表为空")
        del self.list[-1]
    """

    # 格式化输出PCB表
    def show_pcbs(self):
        print('-'*30)
        print("{:8}{:15}{:25}{:8}".format("PID", "Status", "Run_time/Need_time", "Priority"))
        for i in self.list:
            print(i)
        for i in self.trash:
            print(i)
        print()


def init_pcbs(pcb_list: PCBLinkedList):
    global global_cpu_time
    global dynamic_pq
    flag = False
    if 'dynamic_pq' in globals():
        flag = True
    
    num = input("要创建的进程数量：")
    num = int(num)
    i = 1
    while i <= num:
        line = input("输入第{}个进程的pid、预计执行时间、优先级（可缺省，默认为5），以空格分隔\n".format(i)).split()
        if len(line) < 2:
            print("输入的信息不足")
            continue
        if pcb_list.pid_exist(int(line[0])):
            print("PID冲突，请换一个PID")
            continue

        if len(line) > 2:
            tmp = PCB(int(line[0]), int(line[1]), global_cpu_time, int(line[2]))
            pcb_list.add_one(tmp)
        else:
            tmp = PCB(int(line[0]), int(line[1]), global_cpu_time)
            pcb_list.add_one(tmp)
        # 存在已有的优先队列，同时将新创建进程的PCB放入其中
        if 'dynamic_pq' in globals():
            dynamic_pq.put(tmp)
        i += 1


# 轮转法
def round_running(pcb_list: PCBLinkedList):
    global global_cpu_time
    # 迭代器用于轮询PCB表
    global RR_cur
    global INTERACTABLE
    if 'RR_cur' not in globals():
        RR_cur = iter(pcb_list)

    # 取得要处理的PCB
    try:
        pcb_pt = next(RR_cur)
    except StopIteration:
        # 迭代器遍历到结尾，从头开始，实现PCB链表循环轮询
        RR_cur = iter(pcb_list)
        pcb_pt = next(RR_cur)

    pcb_pt.cpu_time += 1
    # 轮转到的进程工作完毕
    if pcb_pt.cpu_time == pcb_pt.total_time:
        pcb_pt.state = PCB.state_done
        pcb_list.delete_one(pcb_pt.pid)
        print("当前CPU时间为{}，{}号进程完成".format(global_cpu_time, pcb_pt.pid))
        if not INTERACTABLE:
            pcb_list.show_pcbs()

# 动态优先级
def dynamic_priority(pcb_list: PCBLinkedList):
    global dynamic_pq
    # 要用的优先队列不存在就创建
    if 'dynamic_pq' not in globals():
        dynamic_pq = PriorityQueue()
        for i in pcb_list:
            dynamic_pq.put(i)

    # 取出优先级最高的进程运行一个CPU刻，并将其优先级减一
    pcb_pt = dynamic_pq.get()
    pcb_pt.cpu_time += 1
    # 防止优先级过低导致的不可预见的问题
    if pcb_pt.priority > -50:
        pcb_pt.priority -= 1
    
    # 当前进程工作完毕
    if pcb_pt.cpu_time == pcb_pt.total_time:
        pcb_pt.state = PCB.state_done
        pcb_list.delete_one(pcb_pt.pid)
        print("\n当前CPU时间为{}，{}号进程完成".format(global_cpu_time, pcb_pt.pid))
        if not INTERACTABLE:
            pcb_list.show_pcbs()
    # 未工作完成，放回优先队列
    else:
        dynamic_pq.put(pcb_pt)

# 高响应比优先
def high_response_ratio(pcb_list: PCBLinkedList):
    global global_cpu_time
    idx = -1
    cur_max = -1
    for k, i in enumerate(pcb_list):
        # 将响应比更新到priority属性中
        # 事实上，等待时间=当前时间-创建时间-已运行时间
        i.priority = 1 + (global_cpu_time-i.create_time-i.cpu_time)/i.total_time
        if i.priority > cur_max:
            idx = k
            cur_max = i.priority
    # 将响应比最高的进程运行一个CPU刻
    pcb_pt = pcb_list.list[idx]
    pcb_pt.cpu_time += 1
    # 当前进程工作完毕
    if pcb_pt.cpu_time == pcb_pt.total_time:
        pcb_pt.state = PCB.state_done
        pcb_list.delete_one(pcb_pt.pid)
        print("\n当前CPU时间为{}，{}号进程完成".format(global_cpu_time, pcb_pt.pid))
        if not INTERACTABLE:
            pcb_list.show_pcbs()


def user_interact(pcb_list: PCBLinkedList):
    global global_cpu_time
    global INTERACTABLE
    if not INTERACTABLE:
        return

    line = input("当前CPU时间为{}，是否添加进程(y/N)".format(global_cpu_time))
    if len(line) != 0:
        line = line[0].upper()
        if line == 'Y':
            init_pcbs(pcb_list)
    
    line = input("是否继续运行到结束(y/N)")
    if len(line) != 0:
        line = line[0].upper()
        if line == 'Y':
            INTERACTABLE = False


def main(scheduling_func):
    # 全局的cpu时刻，表示的是第n个单位时间
    # 可以理解为第n个单位时间结束的时刻
    global global_cpu_time
    global INTERACTABLE
    global_cpu_time = 0

    pcb_list = PCBLinkedList()
    init_pcbs(pcb_list)

    # 系统主循环，若PCB链表不为空，系统继续运行
    while not pcb_list.is_empty():
        global_cpu_time += 1
        scheduling_func(pcb_list)
        if INTERACTABLE:
            pcb_list.show_pcbs()
        user_interact(pcb_list)


if __name__ == "__main__":
    # 在下面直接给入要使用的算法函数即可
    # 已经实现的有轮转法round_running、动态优先级dynamic_priority与高响应比优先high_response_ratio
    main(high_response_ratio)
