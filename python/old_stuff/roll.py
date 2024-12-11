from simpleeval import simple_eval
import re
import bisect
import random
import warnings


def help() -> None:
    ###Displays the help information for composing dice strings.

    help_text = """
    Declaring the operators to be used in dice notation.
    DIE OPERATORS
    d = dice. Indicates that a dice is being rolled. The number following the
        d indicates how many sides the dice is. While, not required, if a
        number is placed before the d, it rolls that dice that many times.
    k = keep. This is used in keep systems, where multiple dice are rolled
        (indicated by the number before the k), and only a number of the 
        highest dice are "kept" when determining the total (the number after 
        the k). L5R uses d10 as a standard, so that is what this defaults to. 
        If you are using a similar system but with a different number of sides, 
        use the "d" dice notation and use the "h" modifying operator.

    MOD OPERATORS
    All mod operators require a number following (the operand).
    h = high. This keeps the highest number of dice indicated by the operand.
    l = low. This keeps the lowest number of dice indicated by the operand.
    c = ceiling. If the number rolled on any given die has a ceiling, the
        operand serves as a cap to the die roll.
    f = floor. The number rolled on any dice can be no lower than the operand.
    p = pool target. In systems where a dice must be above a certain number to
        be considered a "success", the operand serves as the target number.
    t = target. This looks for the overall target of the sum of all kept rolls.

    EXPLOSION
    An explosion operator has no operands. It is a modifier that indicates that
        the dice should "explode" (rolled again, and the result added to the
        total) when a die's max value is rolled. This is a recursive modifier -
        if an exploded roll also rolls the max value, it also explodes.
    Note: A "k" die operator automatically explodes.

    MATH AND PARENTHESES OPERATORS
    This library supports a string entered in to modify dice rolling results.
        The only supported operators are addition, subtraction, multiplication,
        division, and parentheses - exponents are not supported.

    Guide to Composing Dice Strings
    ------------------------------

    Basic Dice Roll:
    - Format: [number of dice]d[number of sides][explode?][operators][operands]
    - Example: '3d6' represents rolling a six-sided die (d6) three times.
    - '5d10': Roll a ten-sided die five times.
    - '4d6l1': Roll four six-sided dice and keep the lowest roll.
    - '3d8!': Roll three eight-sided dice, rolling again for any results of eight.
    - '(3d6+2)*4': Roll three six-sided dice, add 2 to the total, and then multiply the result by 4.

    Notes:
    - Ensure the format is strictly followed to avoid errors.
    - There are simple functions available for simpler rolls.

    Methods:
    -------
    The following methods accept modifiers:
        - roll.dice(roll_str): returns the total of the dice roll string. 
        - roll.mrolls(*roll_str): returns list of dice rolls, accepts multiple
        dice arguments.
        - roll.results(dice_str): returns the results of the individual rolls 
        in a list. 
        - roll.kresults(dice): returns the results of kept rolls in a list. 
        - roll.math(dice_str): returns total of an expression that includes
        dice notation.

    The following methods only use the 'd' operator:
        - roll.pool(dice, target): returns number of success given a target
        number per die. 
        - roll.fpool(dice, target): returns number of failures given a target
        number per die. 
        - roll.success(dice, target): Boolean check to see if sum off all dice
        beat target number
        - roll.advantage(dice): Rolls twice the dice indicated, keeps highest.
        - roll.disadvantage(dice):Rolls twice the dice indicated, keeps lowest.

    """

    print(help_text)


DIE_OPERATORS = ["d", "k", "h", "l", "c", "f", "p", "t", "!"]
MATH_OPERATORS = ["(", ")", "+", "-", "/", "*"]
MATH_MAP = {
    "(": "( ",
    ")": " )",
    "+": " + ",
    "-": " - ",
    "/": " / ",
    "*": " * ",
}
OPERATOR_MAP = {
    "h": " h ",
    "l": " l ",
    "c": " c ",
    "f": " f ",
    "p": " p ",
    "t": " t ",
}
OPERATORS = DIE_OPERATORS + MATH_OPERATORS
VALID_CHARS = set(OPERATORS).union(set(map(str, range(10))))


def simple_validate(dice) -> str:
    filtered = "".join(filter(set("d1234567890").__contains__, dice.lower()))
    invalid = set(dice.lower()) - set(filtered)
    if invalid or not filtered:  # String was empty or only invalid chars
        raise ValueError("Invalid input string.")
    return dice


class Equation:
    def __init__(self, roll_string) -> None:
        self.end_str = self.validate_string(roll_string)
        self.total = simple_eval(self.end_str)

        """
        Validates a dice string by:
            - Trims whitespace
            - Makes sure parentheses are balanced
            - Removing any invalid characters
            - Logging a warning for any characters removed
            - Mapping any operator symbols to standard syntax
            - Returning the split, validated string
        """

    def validate_string(self, dice_string) ->str:
        if "." in dice_string:
            raise ValueError("Cannot process decimal numbers.")
        dice_string = dice_string.replace(" ", "")
        filtered = "".join(
            filter(VALID_CHARS.__contains__, dice_string.lower())
        )
        invalid = set(dice_string.lower()) - set(filtered)

        if invalid:
            warnings.warn("Invalid characters were removed.")
        
        if not filtered:  # String was empty or only invalid chars
            raise ValueError("Invalid input string.")
        
        if dice_string.count('(') != dice_string.count(')'):
            raise SyntaxError("Error: Unbalanced parentheses.")
        
        mapped = "".join(map(lambda x: MATH_MAP.get(x, x), filtered))
        parts = mapped.split()
        for i, part in enumerate(parts):
            if any(op in part for op in DIE_OPERATORS):
                roll_dice = Dice(part)
                parts[i] = str(roll_dice.total)
        return "".join(parts)


class Dice:
    def __init__(self, starting_string) -> None:
        self.explode = False
        self.operators = []
        self.operands = []
        self.dice_count = 1
        self.dice_string = self.validate_dice(starting_string)
        self.parse_dice(self.dice_string)
        self.dice_mods = list(zip(self.operators, self.operands))
        self.sides = self.operands[0]
        self.rolls = []
        self.exploded_rolls = []
        self.kept_rolls = []
        self.pool_successes = []
        self.target_success = True
        self.mod_functions = {
            "h": lambda n: self.keep_high(n),
            "l": lambda n: self.keep_low(n),
            "c": lambda n: self.ceiling(n),
            "f": lambda n: self.floor(n),
            "p": lambda n: self.pool_check(n),
            "t": lambda n: self.target_check(n),
        }
        self.roll_dice(self.sides)
        if self.explode == True:
            self.explode_dice(self.sides)
        self.total = sum(self.rolls)
        for operator, operand in self.dice_mods:
            if operator in self.mod_functions:
                self.mod_functions[operator](operand)

    def validate_dice(self, dice_string) -> str:
        """
        This is where the dice portion of the string is validated:
            - Ensures a dice can be rolled
            - Makes sure that the string doesn't have k AND d (makes the k an h instead)
            - Converts k notation to d for later parsing
            - Checks for duplicates
        This also checks to make sure that this is only a dice string, since in theory,
        it can be called separately as a class.
        """
        filtered = "".join(
            filter("".join(DIE_OPERATORS).__contains__, dice_string.lower())
        )
        invalid = set(dice_string.lower()) - set(filtered) - set("0123456789")

        if invalid or not filtered:
            raise SyntaxError("Invalid characters found in string.")
        
        indexed_op = None
        for op in filtered:
            indexed_op = dice_string.index(op)
            if op in DIE_OPERATORS and not "!":
                if (
                    indexed_op == len(dice_string) - 1
                    or not dice_string[indexed_op + 1].isdigit()
                ):
                    raise SyntaxError(f'Number must follow "{op}"')

            if op == "k":
                if (
                    indexed_op > 0 and not dice_string[indexed_op - 1].isdigit()
                ) or (
                    indexed_op == len(dice_string) - 1
                    or not dice_string[indexed_op + 1].isdigit()
                ):
                    raise SyntaxError(f'"{op}" requires number on both sides')

        if "d" not in dice_string and "k" not in dice_string:
            raise ValueError(
                'Missing dice roll, notation must include a "d" or "k".'
            )

        if "d" in dice_string and "k" in dice_string:
            warnings.warn(
                '"d" & "k" both present, keeping highest indicated by "k"'
            )
            dice_string = dice_string.replace("k", "h")

        if "k" in dice_string:
            dice_string = dice_string.replace("k", "d10h")

        if "h" in dice_string and "l" in dice_string:
            raise SyntaxError("Cannot keep both high and low rolls.")
        duplicates = [m for m in DIE_OPERATORS if dice_string.count(m) > 1]

        if duplicates:
            raise ValueError("Duplicate operators were found in input string")
        
        return dice_string

    def parse_dice(self, dice_string) -> None:
        if "!" in dice_string:
            self.explode = True
            dice_string = dice_string.replace("!", "")

        split_char = "d" if "d" in dice_string else "k"
        parts = re.split("[a-z]+", dice_string)
        if parts[0] == '':
            parts[0] = 1
        self.dice_count = int(parts.pop(0))
        self.operators = list(filter(lambda x: x in DIE_OPERATORS, dice_string))
        if self.operators[0] != split_char:
            raise ValueError(f"{split_char} is not the first operator.")
        self.operands = [int(num) for num in parts if num]
        

        """
        The functions that follow will be called only if the relevant 
        operator is present (with the exception of the roll_dice function, which
        is always called).
        """

    def roll_dice(self, sides) -> None:
        self.rolls = [
            random.randint(1, int(sides)) for _ in range(self.dice_count)
        ]
        self.kept_rolls = self.rolls

    def explode_dice(self, sides) -> None:
        new_rolls = self.rolls.copy()
        while sides in new_rolls and sides != 0:
            rolls_following_explosion = [
                random.randint(1, int(sides))
                for _ in new_rolls
                if _ == int(sides)
            ]
            self.exploded_rolls += rolls_following_explosion
            self.rolls += rolls_following_explosion
            new_rolls = rolls_following_explosion

    def keep_high(self, high) -> None:
        self.kept_rolls = sorted(self.rolls, reverse=True)[:high]
        self.total = sum(self.kept_rolls)

    def keep_low(self, low):
        self.kept_rolls = sorted(self.rolls)[:low]
        self.total = sum(self.kept_rolls)

    def ceiling(self, ceiling):
        self.total = min(ceiling, self.total)

    def floor(self, floor):
        self.total = max(floor, self.total)

    def pool_check(self, targets):
        keep = self.kept_rolls if self.kept_rolls != [] else self.rolls
        threshold = bisect.bisect_left(sorted(keep), targets)
        self.pool_successes = len((keep)[threshold:])
        if self.pool_successes == None:
            self.pool_successes = 0

    def target_check(self, target):
        if target <= self.total:
            self.total_success = True
        elif target >= self.total:
            self.total_success = False


def dice(roll_str):
    roll_str = simple_validate(roll_str)
    result = Dice(roll_str)
    return result.total


def results(roll_str):
    result = Dice(roll_str)
    return result.rolls


def kresults(roll_str):
    result = Dice(roll_str)
    return result.kept_rolls


def d100():
    return random.randint(0, 100)


def pool(dice_str, target):
    roll_str = f"{dice_str}p{target}"
    result = Dice(roll_str)
    return result.pool_successes


def fpool(dice_str, target):
    roll_str = f"{dice_str}p{target}"
    result = Dice(roll_str)
    return result.dice_count - result.pool_successes


def success(dice_str, target):
    roll_str = f"{dice_str}t{target}"
    result = Dice(roll_str)
    return result.total_success


def advantage(dice_str):
    parts = dice_str.split("d")
    sides = parts[1]
    if parts[0].isdigit():
        dice_rolled = int(parts[0]) * 2
        keep = parts[0]
    else:
        dice_rolled, keep = 2, 1
    advantage_roll = Dice(f"{dice_rolled}d{sides}h{keep}")
    return advantage_roll.total


def disadvantage(dice_str):
    parts = dice_str.split("d")
    sides = parts[1]
    if parts[0].isdigit():
        dice_rolled = int(parts[0]) * 2
        keep = parts[0]
    else:
        dice_rolled, keep = 2, 1
    advantage_roll = Dice(f"{dice_rolled}d{sides}l{keep}")
    return advantage_roll.total


def mrolls(*roll_str):
    results = []
    for roll_string in roll_str:
        result = Dice(roll_string)
        results += result.total
        return results


def math(dice_str):
    result = Equation(dice_str)
    return result.total


def mmath(*dice_str):
    results = []
    for dice_string in dice_str:
        result = Equation(dice_string)
        results.append(result.total)
    return results


def min_max(dice_str, minimum=float("inf"), maximum=float("inf")) -> int:
    result = Equation(dice_str)
    total = result.total
    total = max(total, minimum)
    total = min(total, maximum)
    return int(total)


def bi_split(roll, items):
    end = bisect.bisect_right(list(items.values()), roll)
    return list(items.keys())[:end]


def bi_seek(roll, items):
    nearest = bisect.bisect_left(list(items.values()), roll)
    if nearest == 0 and roll < list(items.values())[0]:
        return list(items.keys())[0]
    elif nearest == len(items) and roll > list(items.values())[-1]:
        return list(items.keys())[-1]
    else:
        return list(items.keys())[nearest]


def bi_search(roll, items):
    closest_key = None
    for key in items.keys():
        key_int = int(key) 
        if key_int <= roll and (closest_key is None or key_int > int(closest_key)):
            closest_key = key
    if closest_key is not None:
        return items[closest_key]
