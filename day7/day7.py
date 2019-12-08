#!/usr/bin/env python3

import asyncio
import enum


class Op(enum.Enum):
    ADD         = 1
    MUL         = 2
    READ        = 3
    WRITE       = 4
    JUMP_IF     = 5
    JUMP_IF_NOT = 6
    LT          = 7
    EQ          = 8
    HALT        = 99


def run_intcode(intcode):
    pc = 0

    while True:
        full_op = intcode[pc]

        modes = full_op // 100
        full_op %= 100

        op = Op(full_op)

        arg_counts = [
            {Op.HALT},
            {Op.READ, Op.WRITE},
            {Op.JUMP_IF, Op.JUMP_IF_NOT},
            {Op.ADD, Op.MUL, Op.LT, Op.EQ},
        ]

        for nargs, arg_count_ops in enumerate(arg_counts):
            if op in arg_count_ops:
                break

        arg_indexes = []
        for i in range(nargs):
            index = pc + i + 1

            if modes % 10 == 0:
                arg_indexes.append(intcode[index])
            else:
                arg_indexes.append(index)

            modes //= 10

        update_pc = True

        if op == Op.ADD:
            intcode[arg_indexes[2]] = intcode[arg_indexes[0]] + intcode[arg_indexes[1]]

        elif op == Op.MUL:
            intcode[arg_indexes[2]] = intcode[arg_indexes[0]] * intcode[arg_indexes[1]]

        elif op == Op.READ:
            intcode[arg_indexes[0]] = yield

        elif op == Op.WRITE:
            yield intcode[arg_indexes[0]]

        elif op in {Op.JUMP_IF, Op.JUMP_IF_NOT}:
            condition = intcode[arg_indexes[0]]
            if op == Op.JUMP_IF_NOT:
                condition = not condition

            if condition:
                pc = intcode[arg_indexes[1]]
                update_pc = False

        elif op == Op.LT:
            intcode[arg_indexes[2]] = int(intcode[arg_indexes[0]] < intcode[arg_indexes[1]])

        elif op == Op.EQ:
            intcode[arg_indexes[2]] = int(intcode[arg_indexes[0]] == intcode[arg_indexes[1]])

        elif op == Op.HALT:
            return

        else:
            assert False, op

        if update_pc:
            pc += nargs + 1


def main():
    with open('input') as fp:
        intcode = list(map(int, ''.join(fp).split(',')))

    INTCODE_AMPLIFIER_COUNT = 5
    max_signal = 0

    part2 = True

    for i in range(INTCODE_AMPLIFIER_COUNT ** INTCODE_AMPLIFIER_COUNT):
        phase_inputs = [i // INTCODE_AMPLIFIER_COUNT ** (INTCODE_AMPLIFIER_COUNT - j - 1)
                        % INTCODE_AMPLIFIER_COUNT + (5 if part2 else 0)
                        for j in range(INTCODE_AMPLIFIER_COUNT)]
        if len(phase_inputs) != len(set(phase_inputs)):
            continue

        current_signal = 0

        if not part2:
            for j in range(INTCODE_AMPLIFIER_COUNT):
                runner = run_intcode(intcode[:])
                next(runner)

                runner.send(phase_inputs[j])
                current_signal = runner.send(current_signal)

                assert current_signal is not None

                try:
                    next(runner)
                except StopIteration:
                    pass
                else:
                    assert False

        else:
            runners = []
            for j in range(INTCODE_AMPLIFIER_COUNT):
                runners.append(run_intcode(intcode[:]))
                next(runners[j])
                runners[j].send(phase_inputs[j])

            while True:
                stopped = False

                for runner in runners:
                    try:
                        current_signal = runner.send(current_signal)
                        next(runner)
                    except StopIteration:
                        stopped = True

                if stopped:
                    break

        max_signal = max(max_signal, current_signal)

    print(max_signal)


if __name__ == '__main__':
    main()
