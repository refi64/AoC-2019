// Implemented in C, *without* using the standard library.

// ========================= BASE TYPEDEFS =========================

typedef unsigned long ulong;

typedef enum boolean boolean;

enum boolean { FALSE, TRUE };

// ========================= SYSTEM CODE =========================

#define SYSCALL_R1 "D"
#define SYSCALL_R2 "S"
#define SYSCALL_R3 "d"

#define SYSCALL_BASE(num, ...) \
  ({ \
    long ret; \
    asm volatile ("syscall" \
                  : "=a" (ret) \
                  : "0" (num), ##__VA_ARGS__ \
                  : "rcx", "r11", "memory"); \
    ret; \
  })

#define SYSCALL_A0(num)           SYSCALL_BASE(num)
#define SYSCALL_A1(num, a)        SYSCALL_BASE(num, SYSCALL_R1 (a))
#define SYSCALL_A2(num, a, b)     SYSCALL_BASE(num, SYSCALL_R1 (a), SYSCALL_R2 (b))
#define SYSCALL_A3(num, a, b, c)  SYSCALL_BASE(num, SYSCALL_R1 (a), SYSCALL_R2 (b), \
                                               SYSCALL_R3 (c))

enum {
  SYS_READ  = 0,
  SYS_WRITE = 1,
  SYS_OPEN  = 2,
  SYS_CLOSE = 3,
  SYS_EXIT  = 60,
};

long read(int fd, char *buf, ulong size) {
  return SYSCALL_A3(SYS_READ, fd, buf, size);
}

long write(int fd, const char *buf, ulong size) {
  return SYSCALL_A3(SYS_WRITE, fd, buf, size);
}

#define O_RDONLY 0

long open(const char *filename, int flags, int mode) {
  return SYSCALL_A3(SYS_OPEN, filename, flags, mode);
}

long close(int fd) {
  return SYSCALL_A1(SYS_CLOSE, fd);
}

void exit(int rc) {
  SYSCALL_A1(SYS_EXIT, rc);
  __builtin_unreachable();
}

// Inspired by Chromium's IMMEDIATE_CRASH.
#define CRASH() \
  do { \
    asm volatile ("int3; ud2"); \
    __builtin_unreachable(); \
  } while (0)

// ========================= STRING UTILITIES =========================

#define LONG_TO_STRING_BUFFER_SIZE 32

ulong strlen(const char *str) {
  ulong i = 0;
  for (i = 0; str[i]; i++);
  return i;
}

void reverse(char *str) {
  ulong len = strlen(str);
  for (ulong i = 0; i < len / 2; i++) {
    char temp = str[i];
    str[i] = str[len - i - 1];
    str[len - i - 1] = temp;
  }
}

void ltos(char *target, long value) {
  char *start = target;

  if (value == 0) {
    *target++ = '0';
  } else {
    if (value < 0) {
      *target++ = '-';
      value = -value;
    }

    while (value) {
      *target++ = '0' + (value % 10);
      value /= 10;
    }
  }

  *target++ = '\0';
  reverse(start);
}

ulong stol(long *target, const char *value) {
  *target = 0;
  ulong i = 0;
  boolean negative = FALSE;

  if (value[i] == '-') {
    negative = TRUE;
    i++;
  }

  for (; value[i] >= '0' && value[i] <= '9'; i++) {
    *target *= 10;
    *target += value[i] - '0';
  }

  if (negative) {
    *target = -*target;
  }

  return i;
}

ulong parse_delimited_numbers(long *target, const char *input, ulong max) {
  ulong i = 0;

  while (i < max) {
    int places_moved = stol(&target[i], input);
    if (places_moved == 0) {
      return 0;
    }

    input += places_moved;
    i++;

    if (*input == '\0') {
      break;
    } else if (*input == ',') {
      input++;
    } else {
      return 0;
    }
  }

  return i;
}

void copy(void *dest, const void *src, ulong count) {
  for (ulong i = 0; i < count; i++) {
    *(unsigned char *)dest++ = *(unsigned char *)src++;
  }
}

ulong chomp(char *str) {
  ulong i = 0, len = strlen(str);
  while (len > 0 && (str[len - 1] == '\n' || str[len - 1] == ' ')) {
    str[--len] = '\0';
    i++;
  }

  return i;
}

// ========================= CLEANUP TOOLS =========================

#define cleanup(func) __attribute__((cleanup(func)))

void perror(const char *str, int err);

void cleanup_close(int *fd) {
  if (*fd >= 0) {
    int r = close(*fd);
    if (r < 0) {
      perror("close", -r);
    }

    *fd = -1;
  }
}

// ========================= I/O UTILS =========================

void fprint(int fd, const char *str) {
  if (write(fd, str, strlen(str)) < 0) {
    CRASH();
  }
}

void fprintln(int fd, const char *str) {
  fprint(fd, str);

  const char newline = '\n';
  if (write(fd, &newline, 1) < 0) {
    CRASH();
  }
}

enum { STDIN, STDOUT, STDERR };

#define print(str)    fprint(STDOUT, str)
#define println(str)  fprintln(STDOUT, str)
#define eprint(str)   fprint(STDERR, str)
#define eprintln(str) fprintln(STDERR, str)

void fprintln_long(int fd, long arg) {
  char buffer[LONG_TO_STRING_BUFFER_SIZE];
  ltos(buffer, arg);
  fprintln(fd, buffer);
}

void perror(const char *str, int err) {
  eprint(str);
  eprint(": ");

  char errbuf[LONG_TO_STRING_BUFFER_SIZE];
  ltos(errbuf, err);
  eprintln(errbuf);
}

boolean read_file_contents(const char *filename, char *buffer, int size) {
  cleanup(cleanup_close) int fd = open("input", 0, O_RDONLY);
  if (fd < 0) {
    perror("open", -fd);
    return FALSE;
  }

  int r = read(fd, buffer, size - 1);
  if (r < 0) {
    perror("read", -r);
    return FALSE;
  }

  buffer[r] = '\0';
  return TRUE;
}

boolean read_long(long *target, const char *prompt) {
  print(prompt);

  char buffer[LONG_TO_STRING_BUFFER_SIZE];
  int r = read(STDIN, buffer, LONG_TO_STRING_BUFFER_SIZE);
  if (r < 0) {
    perror("read_long", -r);
    return FALSE;
  }

  r -= chomp(buffer);
  if (stol(target, buffer) != r) {
    eprintln("stol failed");
    return FALSE;
  }

  return TRUE;
}

// ========================= INTCODE =========================

typedef enum intcode_op intcode_op;

enum intcode_op {
  INTCODE_ADD   = 1,
  INTCODE_MUL,
  INTCODE_READ,
  INTCODE_WRITE,
  INTCODE_JUMP_IF,
  INTCODE_JUMP_IF_NOT,
  INTCODE_LT,
  INTCODE_EQ,
  INTCODE_HALT  = 99,
};

void run_intcode(long *intcode) {
  ulong pc = 0;

  for (;;) {
    intcode_op op = intcode[pc];
    if (op == INTCODE_HALT) {
      break;
    }

    int modes = op / 100;
    op %= 100;

    int nargs;
    switch (op) {
    case INTCODE_ADD:
    case INTCODE_MUL:
    case INTCODE_LT:
    case INTCODE_EQ:
      nargs = 3;
      break;
    case INTCODE_READ:
    case INTCODE_WRITE:
      nargs = 1;
      break;
    case INTCODE_JUMP_IF:
    case INTCODE_JUMP_IF_NOT:
      nargs = 2;
      break;
    case INTCODE_HALT:
      nargs = 0;
      break;
    default:
      eprint("Unexpected opcode: ");
      fprintln_long(STDERR, op);
      CRASH();
    }

    long *args[3];

    for (ulong i = 0; i < nargs; i++) {
      args[i] = &intcode[pc + 1 + i];

      if (modes % 10 == 0) {
        args[i] = &intcode[*args[i]];
      }

      modes /= 10;
    }

    boolean update_pc = TRUE;

    switch (op) {
    case INTCODE_ADD:
      *args[2] = *args[0] + *args[1];
      break;
    case INTCODE_MUL:
      *args[2] = *args[0] * *args[1];
      break;
    case INTCODE_READ:
      read_long(args[0], "Enter an input value: ");
      break;
    case INTCODE_WRITE:
      fprintln_long(STDOUT, *args[0]);
      break;
    case INTCODE_JUMP_IF:
    case INTCODE_JUMP_IF_NOT:
      if (op == INTCODE_JUMP_IF ? *args[0] : !*args[0]) {
        if (*args[1] < 0) {
          eprintln("Invalid pc value in jump-if");
          CRASH();
        }

        pc = *args[1];
        update_pc = FALSE;
      }

      break;
    case INTCODE_LT:
      *args[2] = *args[0] < *args[1];
      break;
    case INTCODE_EQ:
      *args[2] = *args[0] == *args[1];
      break;
    case INTCODE_HALT:
      return;
    }

    if (update_pc) {
      pc += 1 + nargs;
    }
  }
}

// ========================= MAIN CODE =========================

void _start() {
  #define MAX_INTCODE_SIZE 1024

  char line[MAX_INTCODE_SIZE * LONG_TO_STRING_BUFFER_SIZE];
  if (!read_file_contents("input", line, sizeof(line))) {
    exit(1);
  }

  chomp(line);

  long intcode[MAX_INTCODE_SIZE];
  ulong res = parse_delimited_numbers(intcode, line, MAX_INTCODE_SIZE);
  if (res == 0 || res == MAX_INTCODE_SIZE) {
    eprintln("Failed to parse intcode number list");
    exit(1);
  }

  run_intcode(intcode);
  exit(0);
}
