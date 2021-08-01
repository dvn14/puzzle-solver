# Maths Puzzle Solver in Prolog

Project with COMP90048 Declarative Programming.

A maths puzzle is a square grid of squares, each to be filled in with a single digit 1–9 (zero is not permitted) satisfying all these constraints:
- each row and each column contains no repeated digits.
- all squares on the diagonal line from upper left to lower right contain the same value.
- the heading of reach row and column (leftmost square in a row and topmost square in a column) holds either the sum or the product of all the digits in that row or column.

## Example

### Unsolved

|  **X** | **14** | **10** | **35** |
|:--:|:--:|:--:|:--:|
| **14** |    |    |    |
| **15** |    |    |    |
| **28** |    |    |    |

### Solved

|  **X** | **14** | **10** | **35** |
|:--:|:--:|:--:|:--:|
| **14** | 7 | 2 | 1 |
| **15** | 3 | 7 | 5 |
| **28** | 4 | 1 | 7 |
