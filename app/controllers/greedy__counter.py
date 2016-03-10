def greedy(instance, n):
	cost = 0
	while n != 0:
		possible_moves = []
		for each_instance in instance:
			if n % each_instance[0] == 0:
				possible_moves.append(each_instance)
		if len(possible_moves) == 0:
			n -=1
			cost +=1
			continue
		ratio = [each[0]/each[1] for each in possible_moves]
		max_ratio = max(ratio)
		all_indices = [j for i, j in enumerate(ratio) if j == max_ratio]
		max_instance = max([instance[index] for index in all_indices], key=lambda item:item[0])
		n = n / instance[0]
		cost += instance[1]
	return cost

#S(n, i) = min for all j < i {n - S(n, j), S(n,j) + all possible moves/cost
# }
#Subproblem = smaller n
#S(i) = the cost for a subproblem of n = i
#S(1) = 1
#S(i) = min {(S(i - 1) + 1 if (i-j) not divisible by any costs)
							# S(i/move[k]), + cost[k] if S(i/move[k]) exists

def optimal(instance, n):
	S[1] = 1
	for i in range(2,n + 1):
		all_moves = []
		all_moves.append(S[i - 1])
		all_moves.append([S[i / each[0]] + each[1] for each in instance if i % each[0] == 0 and i / each[0] > 0])
		S[i] = min(all_moves)
	return S[n]

def smallest_n(instance):
	n = 0
	while optimal(instance, n) == greedy(instance, n):
		n+=1
	return n

def is_valid(n, moves, strategy):
    cost = 0
    for move in strategy:
        if move not in moves:
            return "Invalid strategy: move {0:d} is not in the set of legal moves".format(move)
        elif move != 1 and n % move != 0:
            return "Invalid strategy: move {0:d} is invalid when n = {1:d}".format(move, n)
        elif n < 0:
            return "Invalid strategy: n drops below 0"
        else:
            n = n - 1 if move == 1 else n // move
            cost += moves[move]
    if n != 0:
        return "Invalid strategy: n is not 0 when all moves have been made"
    return 'Valid strategy with cost {0:d}'.format(cost)

def check_strategy():
    moves = input('Enter an instance in the format x_1,y_1 x_2,y_2 ... x_m,y_m or . if done: ').strip()
    if moves is '.' or moves is '':
        return False
    moves = moves.split()
    move_dict = {1: 1}
    for move in moves:
        move = move.split(',')
        move_dict[int(move[0])] = int(move[1])
    n = int(input('Enter the value of n: '))
    strategy = map(int, input('Enter the moves used on a single line, separated by spaces: ').strip().split())
    print(is_valid(n, move_dict, strategy))
    return True

print('Enter instances, values of n and strategies to check if the strategy is valid and get the cost of the strategy if it is. Instances should be entered in the format x_1,y_1 x_2,y_2 ... x_m,y_m with no spaces between the moves and their costs and spaces separating the move cost pairs. Strategies should be entered as a list of space separated moves, entering 1 for the subtrac one move. When you are done, enter . for the set of moves to exit. An example of the correct format is shown below.\n Enter an instance in the format x_1,y_1 x_2,y_2 ... x_m,y_m or . if done: 3,1 2,1\nEnter the value of n: 10\nEnter the moves used on a single line, separated by spaces: 2 1 2 2 1\nValid strategy of cost 5')

while check_strategy():
    pass






