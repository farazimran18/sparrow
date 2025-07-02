.globl  main

.data
hello_string:
  .string "Hello, World!\n"

.text
main:
  # Print the string to stdout (file descriptor 1)
  li a0, 1             # File descriptor (1 for stdout)
  la a1, hello_string  # Pointer to the string
  li a2, 13            # Length of the string
  li a7, 64            # 64 is the sys_write syscall number
  ecall

  # Exit the program
  li a7, 93    # 93 is the sys_exit syscall number
  li a0, 0     # Exit status (0 for success)
  ecall
