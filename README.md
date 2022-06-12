<div align="center">

<a href="https://github.com/AdelRizq/A3E" rel="noopener">

![Group 231](https://user-images.githubusercontent.com/40351413/173249976-b40968ad-c8b5-49ea-aac5-9c68692820ef.png)
</div>

<h3 align="center">A3E Compiler</h3>

<div align="center">

[![GitHub contributors](https://img.shields.io/github/contributors/AdelRizq/A3E)](https://github.com/AdelRizq/A3E/contributors)
[![GitHub issues](https://img.shields.io/github/issues/AdelRizq/A3E)](https://github.com/AdelRizq/A3E/issues)
[![GitHub forks](https://img.shields.io/github/forks/AdelRizq/A3E)](https://github.com/AdelRizq/A3E/network)
[![GitHub stars](https://img.shields.io/github/stars/AdelRizq/A3E)](https://github.com/AdelRizq/A3E/stargazers)
[![GitHub license](https://img.shields.io/github/license/AdelRizq/A3E)](https://github.com/AdelRizq/A3E/blob/master/LICENSE)

<img src="https://img.shields.io/github/languages/count/AdelRizq/A3E" />
<img src="https://img.shields.io/github/languages/top/AdelRizq/A3E" />
<img src="https://img.shields.io/github/languages/code-size/AdelRizq/A3E" />
<img src="https://img.shields.io/github/issues-pr-raw/AdelRizq/A3E" />

</div>

## About The Project

> **A3E** is a simple programming language compiler similar to C++ built using Flex and Bison and a simple GUI for testing.
  
- You can try it using `gui.exe`

## Build with

- [Flex](http://alumni.cs.ucr.edu/~lgao/teaching/flex.html): Fast Scanner Generator similar to Lex
- [Bison](https://www.gnu.org/software/bison/): Parser Generator similar to Yacc

## Screenshots

<img src="https://user-images.githubusercontent.com/40351413/173253634-ab7a502d-8275-4967-adbd-0edacb2affa6.png">

<img src="https://user-images.githubusercontent.com/40351413/173253662-dec7e91c-86a9-4e81-be0a-d443c66de17f.png">

## Language Description

### Tokens

1. Variables and constants declaration
   - Define variable: *datatype id = value;*
     - Example: `int a = 5;`
  
   - Define constant: *const datatype id = value;*
     - Example: `const int a = 5;`
  
2. Mathematical and Logical expressions
   - Mathematical operations
     - +, -, *, /, %
   - Logical operations
     - ||, &&, ^, !
     - \>, <, >=, <=
   - Any level of parentheses/complexity.
  
3. Assignment statements
   - Variable = expression
     - Example: `a = 5 * b + c;`
</br>
  
4. If-endif, if-else statements
<img src="https://user-images.githubusercontent.com/40351413/173253220-87f24fd2-a9fd-490e-932d-531b1d4ede8f.png" width=300>
</br>

5. While loops
<img src="https://user-images.githubusercontent.com/40351413/173253246-22a68f43-2652-4b65-800f-0e5762274b27.png" width=300>
</br>

6. For loops
<img src="https://user-images.githubusercontent.com/40351413/173253263-e1fe81e8-032f-49e8-969e-d8a120bd2587.png" width=300>
</br>

7. Repeat until
<img src="https://user-images.githubusercontent.com/40351413/173253302-353f8126-ccfb-4a56-98a8-d4afb9c79dd7.png" width=300px>
</br>

8. Switch case
<img src="https://user-images.githubusercontent.com/40351413/173253299-039565f8-1b2c-472d-9b32-633e1f83ddb8.png" width=300px>
</br>

9. Block structures
<img src="https://user-images.githubusercontent.com/40351413/173253297-69e35012-0f5e-41c5-8293-8a25a3f605dc.png" width=300px>

### Quadruples

|   Quadruple   |                                   Description                                   |
|:-------------:|:-------------------------------------------------------------------------------:|
| ADD s1, s2, R |           Pop the top 2 values of the stack (s1, s2) and push s1 + s2           |
| SUB s1, s2, r |           Pop the top 2 values of the stack (s1, s2) and push s1 - s2           |
| MUL s1, s2, r |           Pop the top 2 values of the stack (s1, s2) and push s1 * s2           |
| DIV s1, s2, r |           Pop the top 2 values of the stack (s1, s2) and push s1 / s2           |
| MOD s1, s2, r |           Pop the top 2 values of the stack (s1, s2) and push s1 % s2           |
| LT s1, s2, r  | Pop the top 2 values of the stack (s1, s2) and push true if s1 < s2 else false  |
| GT s1, s2, r  | Pop the top 2 values of the stack (s1, s2) and push true if s1 > s2 else false  |
| LE s1, s2, r  | Pop the top 2 values of the stack (s1, s2) and push true if s1 <= s2 else false |
| GE s1, s2, r  | Pop the top 2 values of the stack (s1, s2) and push true if s1 >= s2 else false |
| EQ s1, s2, r  | Pop the top 2 values of the stack (s1, s2) and push true if s1 == s2 else false |
| NE s1, s2, r  | Pop the top 2 values of the stack (s1, s2) and push true if s1 != s2 else false |
|   NOT s1, r   |                Pop the top 2 values of the stack (s) and push !s                |
| AND s1, s2, r |      Pop the top 2 values of the stack (s1, s2) and push true if s1 && s2       |
|OR s1, s2, r|Pop the top 2 values of the stack (s1, s2) and push true if s1 || s2|
|XOR s1, s2, r|Pop the top 2 values of the stack (s1, s2) and push s1 ^ s2|
|PUSH value|Push value to the stack|
|POP dst|Pop the top of the stack in into dst|
|L<num>:|Add label with number num|
|JMP L|Unconditional jump to L|
|JZ L|Jump to L if stack top == 0|
|B<num>:|Add break label with the scope number|

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b AmazingFeature-Feat`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin AmazingFeature-Feat`)
5. Open a Pull Request

## License

- This software is licensed under **MIT License**, See [License](https://github.com/AdelRizq/A3E/blob/main/LICENSE) for more information.
