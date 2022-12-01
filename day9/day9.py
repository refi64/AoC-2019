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
    ADJUST_BASE = 9
    HALT        = 99


def run_intcode(intcode):
    pc = 0
    rel = 0

    while True:
        full_op = intcode[pc]

        modes = full_op // 100
        full_op %= 100

        op = Op(full_op)

        arg_counts = [
            {Op.HALT},
            {Op.READ, Op.WRITE, Op.ADJUST_BASE},
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
            elif modes % 10 == 1:
                arg_indexes.append(index)
            elif modes % 10 == 2:
                arg_indexes.append(rel + intcode[index])

            modes //= 10

        update_pc = True

        if op == Op.ADD:
            intcode[arg_indexes[2]] = intcode[arg_indexes[0]] + intcode[arg_indexes[1]]

        elif op == Op.MUL:
            intcode[arg_indexes[2]] = intcode[arg_indexes[0]] * intcode[arg_indexes[1]]

        elif op == Op.READ:
            intcode[arg_indexes[0]] = int(input('Enter an input number: '))

        elif op == Op.WRITE:
            print(intcode[arg_indexes[0]])

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

        elif op == Op.ADJUST_BASE:
            rel += intcode[arg_indexes[0]]

        elif op == Op.HALT:
            return

        else:
            assert False, op

        if update_pc:
            pc += nargs + 1


def main():
    with open('input') as fp:
        intcode = list(map(int, ''.join(fp).split(',')))

    intcode.extend(0 for _ in range(999))
    run_intcode(intcode)

if __name__ == '__main__':
    main()
