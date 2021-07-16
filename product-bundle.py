from typing import List, Tuple, Dict


class CharacterTable:
    def __init__(self, name: str):
        with open("{}-character-table".format(name)) as data:
            self.character_table: List[List[int]] = []
            self.classes, self.size = (int(x) for x in data.readline().split())
            self.centralizer_sizes: List[int] = [
                int(x) for x in data.readline().split()
            ]
            self.class_sizes: List[int] = [int(x) for x in data.readline().split()]
            for _ in range(self.classes):
                self.character_table.append([int(x) for x in data.readline().split()])
            self.multiplication_table = [
                [[0] * self.classes for _ in range(self.classes)]
                for _ in range(self.classes)
            ]
            self.prepare_multiplication_table()

    def inner_product(self, chi: List[int], sigma: List[int]) -> int:
        product = sum(
            chi[i] * sigma[i] * self.class_sizes[i] for i in range(self.classes)
        )
        if product % self.size:
            print("inner product of non-integral characters {chi}, {sigma}")
        return (
            sum(chi[i] * sigma[i] * self.class_sizes[i] for i in range(self.classes))
            // self.size
        )

    def decompose(self, chi: List[int]) -> List[int]:
        return [
            self.inner_product(chi, self.character_table[i])
            for i in range(self.classes)
        ]

    def prepare_multiplication_table(self) -> None:
        for i in range(self.classes):
            for j in range(i, self.classes):
                rho = self.character_table[i]
                sigma = self.character_table[j]
                chi = [rho[i] * sigma[i] for i in range(self.classes)]
                decomposition = self.decompose(chi)
                self.multiplication_table[i][j] = decomposition
                self.multiplication_table[j][i] = decomposition

    def multiply(self, rho: List[int], sigma: List[int]) -> List[int]:
        return [
            sum(
                self.multiplication_table[i][j][k] * rho[i] * sigma[j]
                for i in range(self.classes)
                for j in range(self.classes)
            )
            for k in range(self.classes)
        ]

    def unit_vector(self, index: int) -> List[int]:
        ret = [0] * self.classes
        ret[index] = 1
        return ret

    def add(self, rho: List[int], sigma: List[int]) -> List[int]:
        return [rho[i] + sigma[i] for i in range(self.classes)]

    def trivial(self) -> List[int]:
        return self.unit_vector(0)

    def invariant(
        self, cohomology: Dict[Tuple[int, int], List[int]]
    ) -> Dict[Tuple[int, int], int]:
        return {degree: coefficient[0] for degree, coefficient in cohomology.items()}

    def to_character(self, multiplicties: List[int]) -> List[int]:
        return [
            sum(
                multiplicties[i] * self.character_table[i][j]
                for i in range(self.classes)
            )
            for j in range(self.classes)
        ]


E6 = CharacterTable("e6")


def add_tuples(x: Tuple[int, int], y: Tuple[int, int]) -> Tuple[int, int]:
    return (x[0] + y[0], x[1] + y[1])


def multiply(
    p: Dict[Tuple[int, int], List[int]], q: Dict[Tuple[int, int], List[int]]
) -> Dict[Tuple[int, int], List[int]]:
    ret: Dict[Tuple[int, int], List[int]] = {}
    for (p_grade, p_coefficient) in p.items():
        for (q_grade, q_coefficient) in q.items():
            grade: Tuple[int, int] = add_tuples(p_grade, q_grade)
            coefficient: List[int] = E6.multiply(p_coefficient, q_coefficient)
            if grade in ret:
                ret[grade] = E6.add(ret[grade], coefficient)
            else:
                ret[grade] = coefficient
    return {
        grade: coefficient
        for grade, coefficient in ret.items()
        if sum(coefficient) != 0
    }


def power(
    p: Dict[Tuple[int, int], List[int]], n: int
) -> Dict[Tuple[int, int], List[int]]:
    if n < 0:
        raise ValueError()
    if not p:
        return {}
    if n == 0:
        return {(0, 0): E6.unit_vector(0)}
    ret = p.copy()
    for _ in range(n - 1):
        ret = multiply(ret, p)
    return ret


# (degree, weight)
moduli_space = {
    (0, 0): E6.trivial(),
    (1, 1): E6.unit_vector(7),
    (2, 2): E6.unit_vector(6),
    (3, 3): [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0],
    (4, 4): [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1],
}

base = moduli_space  # multiply(multiply(multiply(moduli_space, {(0, 0): E6.trivial(), (3, 2): E6.trivial()}), {(0, 0): E6.trivial(), (5, 3): E6.trivial()}), {(0, 0): E6.trivial(), (7, 4): E6.trivial()})


def fiber(n: int) -> Dict[Tuple[int, int], List[int]]:
    fiber_1 = {
        (0, 0): E6.trivial(),
        (2, 1): E6.add(E6.trivial(), E6.unit_vector(1)),
        (4, 2): E6.trivial(),
    }
    return power(fiber_1, n)


def alternating_sum(cohomology: Dict[Tuple[int, int], int]) -> Dict[int, int]:
    ret: Dict[int, int] = {}
    for (degree, weight), coefficient in cohomology.items():
        signed_coefficient = coefficient * (-1 if degree % 2 else 1)
        if weight in ret:
            ret[weight] += signed_coefficient
        else:
            ret[weight] = signed_coefficient
    return {
        weight: coefficient for weight, coefficient in ret.items() if coefficient != 0
    }


def polynomial(n: int) -> Dict[int, int]:
    return {
        (2 * n - weight): coefficient
        for weight, coefficient in alternating_sum(
            E6.invariant(multiply(fiber(i), base))
        ).items()
    }


for representation in base.values():
    print(E6.to_character(representation))
for representation in fiber(1).values():
    print(E6.to_character(representation))

print("{")
for i in range(1, 9):
    for exponent, coefficient in polynomial(i).items():
        print(
            "{coefficient} q^({exponent}) + ".format(
                exponent=exponent, coefficient=coefficient
            ),
            end="",
        )
    print(" , ")
print("}")
