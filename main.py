import sys


def fib(n: int) -> int:
    """Return the nth Fibonacci number (0-indexed: fib(0)=0, fib(1)=1)."""
    if n == 0:
        return 0
    a, b = 0, 1
    for _ in range(1, n):
        a, b = b, a + b
    return b


def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: python main.py <n>", file=sys.stderr)
        print("  n: non-negative integer", file=sys.stderr)
        sys.exit(1)

    arg = sys.argv[1]

    try:
        n = int(arg)
    except ValueError:
        print(f"Error: '{arg}' is not a valid integer", file=sys.stderr)
        sys.exit(1)

    if n < 0:
        print(f"Error: {n} is negative; expected a non-negative integer", file=sys.stderr)
        sys.exit(1)

    print(fib(n))


if __name__ == "__main__":
    main()