
%include "macros.mac"
global _start

struc Game
    .board:
        resb 9
        alignb 16
    .player:
        resb 1
        alignb 16
endstruc

section .data
line: db ' +---+---+---+',10
line.len equ $ - line
row: db ' | |',10,
player: db 'Player'
question: db ' enter your next move:',10
question.len equ $ - question
winmsg: db ' has won!',10
winmsg.len equ $ - winmsg
wincases: dw 111000000b, 000111000b, 000000111b, 100100100b, 010010010b, 001001001b, 100010001b, 001010100b

section .text
_start:
    sub rsp, Game_size ; allocate game on stack
    mov rdi, rsp ; setting the first argument to the address of the game
    call init_game
    mov rdi, rsp ; setting the first argument to the address of the board
    call print_board
L1:
    print player, 7
    mov rdi, rsp
    add rdi, Game.player
    print rdi, 1
    print question, question.len
    sub rsp, 16 ; allocate buf for user input on stack
    ; read next 2 characters from stdin
    mov rax, 0
    mov rdi, 0
    mov rsi, rsp
    mov rdx, 3
    syscall
    mov r10b, byte[rsp]
    mov r11b, byte[rsp+1]
    mov r12b, byte[rsp+2]
    add rsp, 16 ; deallocate buf for user input from stack
    cmp r12b, 10
    jne L1
    cmp r10b, 'a'
    je col_a
    cmp r10b, 'b'
    je col_b
    cmp r10b, 'c'
    je col_c
    jmp L1
col_a:
    mov r10, 0
    jmp after_col
col_b:
    mov r10, 1
    jmp after_col
col_c:
    mov r10, 2
    jmp after_col
after_col:
    cmp r11b, '1'
    je after_row
    cmp r11b, '2'
    je row_2
    cmp r11b, '3'
    je row_3
    jmp L1
row_2:
    add r10, 3
    jmp after_row
row_3:
    add r10, 6
    jmp after_row
after_row:
    cmp byte[rsp+Game.board+r10], ' '
    jne L1
    mov r11b, byte[rsp+Game.player]
    mov byte[rsp+Game.board+r10], r11b
    mov rdi, rsp
    call print_board
    ; check win
    mov r10b, byte[rsp+Game.player]
    mov r11, 0
    mov rcx, 9
L2:
    cmp byte[rsp+Game.board+rcx-1], r10b
    jne L2_condition
    mov r12, 1
    shl r12, cl
    or r11, r12
L2_condition:
    loop L2
    shr r11, 1
    mov rcx, 8
L3:
    mov r13w, word[wincases+(rcx-1)*2]
    mov r12w, r11w
    and r12w, r13w
    cmp r12w, r13w
    je win
    loop L3
    cmp r10b, 'X'
    je player_x
    mov byte[rsp+Game.player], 'X'
    jmp L1
player_x:
    mov byte[rsp+Game.player], 'O'
    jmp L1
win:
    print player, 7
    mov rdi, rsp
    add rdi, Game.player
    print rdi, 1
    print winmsg, winmsg.len
    add rsp, Game_size ; deallocate game from stack
    exit 0

init_game:
    mov r10, 9
init_game_L1:
    dec r10
    mov byte[rdi+Game.board+r10], ' '
    jnz init_game_L1
    mov byte[rdi+Game.player], 'X'
    ret

print_board:
    push rdi
    mov r12, 3
print_board_L1:
    print line, line.len
    mov r13, 3
print_board_L2:
    print row, 3
    print [rsp], 1
    inc qword[rsp]
    dec r13
    jnz print_board_L2
    print row+2, 3
    dec r12
    jnz print_board_L1
    print line, line.len
    pop rdi
    ret
