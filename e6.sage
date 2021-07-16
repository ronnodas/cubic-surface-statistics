import functools
from collections import defaultdict
from collections.abc import Iterable, Collection
from enum import Enum
from typing import Any, Optional, TypeVar

from sage.all import *
from sage.groups.class_function import ClassFunction
from sage.plot.plot3d.implicit_plot3d import implicit_plot3d


class Line(Enum):
    E1 = "E_1"
    E2 = "E_2"
    E3 = "E_3"
    E4 = "E_4"
    E5 = "E_5"
    E6 = "E_6"
    F1 = "F_1"
    F2 = "F_2"
    F3 = "F_3"
    F4 = "F_4"
    F5 = "F_5"
    F6 = "F_6"
    G12 = "G_{12}"
    G13 = "G_{13}"
    G14 = "G_{14}"
    G15 = "G_{15}"
    G16 = "G_{16}"
    G23 = "G_{23}"
    G24 = "G_{24}"
    G25 = "G_{25}"
    G26 = "G_{26}"
    G34 = "G_{34}"
    G35 = "G_{35}"
    G36 = "G_{36}"
    G45 = "G_{45}"
    G46 = "G_{46}"
    G56 = "G_{56}"


class ConjugacyClass(Enum):
    def __init__(
        self,
        me: str,
        atlas: str,
        swinnerton_dyer: str,
        representative: list[tuple[Line, ...]],
    ) -> None:
        self.me = f"({me})"
        self.atlas = atlas
        self.swinnerton_dyer = swinnerton_dyer
        self.representative = representative

    identity = ("1^6", "1A", "C_1", [])
    two_a = (
        "1^{-2}, 2^4",
        "2A",
        "C_3",
        [
            (Line.E1, Line.F3),
            (Line.E2, Line.F6),
            (Line.E3, Line.F1),
            (Line.E4, Line.F5),
            (Line.E5, Line.F4),
            (Line.E6, Line.F2),
            (Line.G12, Line.G36),
            (Line.G14, Line.G35),
            (Line.G15, Line.G34),
            (Line.G16, Line.G23),
            (Line.G24, Line.G56),
            (Line.G25, Line.G46),
        ],
    )
    two_b = (
        "1^2, 2^2",
        "2B",
        "C_2",
        [
            (Line.E1, Line.G56),
            (Line.E2, Line.G45),
            (Line.E4, Line.G25),
            (Line.E5, Line.F3),
            (Line.E6, Line.G15),
            (Line.F1, Line.G36),
            (Line.F2, Line.G34),
            (Line.F4, Line.G23),
            (Line.F6, Line.G13),
            (Line.G16, Line.G24),
        ],
    )
    two_c = (
        "1^4, 2",
        "2C",
        "C_{16}",
        [
            (Line.E4, Line.G56),
            (Line.E5, Line.G46),
            (Line.E6, Line.G45),
            (Line.F1, Line.G23),
            (Line.F2, Line.G13),
            (Line.F3, Line.G12),
        ],
    )
    two_d = (
        "2^3, 2^2",
        "2D",
        "C_{17}",
        [
            (Line.E1, Line.G16),
            (Line.E2, Line.G26),
            (Line.E4, Line.G56),
            (Line.E5, Line.G46),
            (Line.E6, Line.F3),
            (Line.F1, Line.G13),
            (Line.F2, Line.G23),
            (Line.F4, Line.G35),
            (Line.F5, Line.G34),
            (Line.G12, Line.G45),
            (Line.G14, Line.G24),
            (Line.G15, Line.G25),
        ],
    )
    three_a = (
        "1^{-3}, 3 ^ 3",
        "3A/3B",
        "C_{11}",
        [
            (Line.E1, Line.F6, Line.G16),
            (Line.E2, Line.F1, Line.G12),
            (Line.E3, Line.G35, Line.F5),
            (Line.E4, Line.G34, Line.F3),
            (Line.E5, Line.G45, Line.F4),
            (Line.E6, Line.F2, Line.G26),
            (Line.G13, Line.G46, Line.G25),
            (Line.G14, Line.G56, Line.G23),
            (Line.G15, Line.G36, Line.G24),
        ],
    )
    three_b = (
        "3^2, 3^3",
        "3C",
        "C_9",
        [
            (Line.E1, Line.G46, Line.G56),
            (Line.E4, Line.E5, Line.G16),
            (Line.E6, Line.G14, Line.G15),
            (Line.F2, Line.G35, Line.G34),
            (Line.F3, Line.G25, Line.G24),
            (Line.F4, Line.G23, Line.F5),
        ],
    )
    three_c = (
        "1^3, 3",
        "3D",
        "C_6",
        [
            (Line.E1, Line.G23, Line.E6),
            (Line.E2, Line.F1, Line.G12),
            (Line.E3, Line.G36, Line.F6),
            (Line.E4, Line.G35, Line.G25),
            (Line.E5, Line.G34, Line.G24),
            (Line.F2, Line.F3, Line.G16),
            (Line.F4, Line.G15, Line.G56),
            (Line.F5, Line.G14, Line.G46),
            (Line.G13, Line.G45, Line.G26),
        ],
    )
    four_a = (
        "1^2, 2^{-2}, 4^2",
        "4A",
        "C_4",
        [
            (Line.E1, Line.G16, Line.G24, Line.G15),
            (Line.E2, Line.G26, Line.G14, Line.G25),
            (Line.E4, Line.G46, Line.G12, Line.G45),
            (Line.E5, Line.F3, Line.E6, Line.G56),
            (Line.F1, Line.G13),
            (Line.F2, Line.G23),
            (Line.F4, Line.G34),
            (Line.F5, Line.F6, Line.G35, Line.G36),
        ],
    )
    four_b = (
        "2, 4",
        "4B",
        "C_5",
        [
            (Line.E1, Line.G34, Line.G13, Line.E4),
            (Line.E2, Line.G35, Line.G23, Line.E5),
            (Line.E3, Line.G45, Line.F6, Line.G12),
            (Line.F1, Line.F5, Line.G16, Line.G56),
            (Line.F2, Line.F4, Line.G26, Line.G46),
            (Line.G14, Line.G15, Line.G25, Line.G24),
        ],
    )
    four_c = (
        "1^{-2}, 2^2, 4",
        "4C",
        "C_{19}",
        [
            (Line.E1, Line.E4, Line.G56, Line.G25),
            (Line.E2, Line.F4, Line.G45, Line.G23),
            (Line.E3, Line.G26),
            (Line.E5, Line.G16, Line.F3, Line.G24),
            (Line.E6, Line.G36, Line.G15, Line.F1),
            (Line.F2, Line.F6, Line.G34, Line.G13),
            (Line.F5, Line.G14),
            (Line.G12, Line.G46),
        ],
    )
    four_d = (
        "1^2, 4",
        "4D",
        "C_{18}",
        [
            (Line.E1, Line.G25, Line.G56, Line.E4),
            (Line.E2, Line.E6, Line.G45, Line.G15),
            (Line.E5, Line.G24, Line.F3, Line.G16),
            (Line.F1, Line.F4, Line.G36, Line.G23),
            (Line.F2, Line.G13, Line.G34, Line.F6),
            (Line.G12, Line.G46),
        ],
    )
    five = (
        "1, 5",
        "5A",
        "C_{15}",
        [
            (Line.E1, Line.E3, Line.G24, Line.G25, Line.G26),
            (Line.E2, Line.G14, Line.F6, Line.F4, Line.G36),
            (Line.E4, Line.E5, Line.E6, Line.G12, Line.G23),
            (Line.F1, Line.G56, Line.G46, Line.G45, Line.F3),
            (Line.F5, Line.G35, Line.G16, Line.G34, Line.G15),
        ],
    )
    six_a = (
        "1, 2^{-2}, 3^{-1}, 6^2",
        "6A/6B",
        "C_{12}",
        [
            (Line.E1, Line.E5, Line.G14, Line.F3, Line.F4, Line.G35),
            (Line.E2, Line.E3, Line.G12, Line.F6, Line.F1, Line.G36),
            (Line.E4, Line.E6, Line.G24, Line.F5, Line.F2, Line.G56),
            (Line.G13, Line.G45, Line.G26),
            (Line.G15, Line.G25, Line.G23, Line.G34, Line.G46, Line.G16),
        ],
    )
    six_b = (
        "1, 2, 3^{-1}, 6",
        "6C/6D",
        "C_7",
        [
            (Line.E1, Line.F4, Line.E6, Line.G56, Line.G23, Line.G15),
            (Line.E2, Line.F1, Line.G13, Line.G45, Line.G36, Line.F6),
            (Line.E3, Line.G26, Line.G12),
            (Line.E4, Line.G25),
            (Line.E5, Line.F3),
            (Line.F2, Line.G34),
            (Line.F5, Line.G14, Line.G46),
            (Line.G16, Line.G24),
        ],
    )
    six_c = (
        "1^{-2}, 2, 6",
        "6E",
        "C_{10}",
        [
            (Line.E1, Line.E6, Line.G23),
            (Line.E2, Line.G12, Line.F1),
            (Line.E3, Line.F6, Line.G36),
            (Line.E4, Line.G24, Line.G35, Line.E5, Line.G25, Line.G34),
            (Line.F2, Line.G16, Line.F3),
            (Line.F4, Line.G46, Line.G15, Line.F5, Line.G56, Line.G14),
            (Line.G13, Line.G26, Line.G45),
        ],
    )
    six_d = (
        "1^{-1}, 2^2, 3, 6^2",
        "6F",
        "C_8",
        [
            (Line.E1, Line.E6, Line.G23),
            (Line.E2, Line.F6, Line.G36, Line.G45, Line.G13, Line.F1),
            (Line.E3, Line.G12, Line.G26),
            (Line.E4, Line.G25),
            (Line.E5, Line.G24),
            (Line.F3, Line.G16),
            (Line.F4, Line.G56, Line.G15),
            (Line.F5, Line.G46, Line.G14),
        ],
    )
    six_e = (
        "1, 2, 3",
        "6G",
        "C_{21}",
        [
            (Line.E1, Line.F3, Line.G23, Line.G16, Line.E6, Line.F2),
            (Line.E2, Line.G45, Line.F1, Line.G26, Line.G12, Line.G13),
            (Line.E3, Line.F6, Line.G36),
            (Line.E4, Line.G15, Line.G35, Line.G56, Line.G25, Line.F4),
            (Line.E5, Line.G14, Line.G34, Line.G46, Line.G24, Line.F5),
        ],
    )
    six_f = (
        "1^{-2}, 2, 3^2",
        "6H",
        "C_{22}",
        [
            (Line.E1, Line.G34, Line.G46, Line.F2, Line.G56, Line.G35),
            (Line.E3, Line.G13),
            (Line.E4, Line.E6, Line.E5, Line.G14, Line.G16, Line.G15),
            (Line.F3, Line.F4, Line.G25, Line.G23, Line.G24, Line.F5),
            (Line.F6, Line.G26),
            (Line.G36, Line.G45),
        ],
    )
    six_g = (
        "6",
        "6I",
        "C_{23}",
        [
            (Line.E1, Line.F3, Line.E6, Line.F2, Line.G23, Line.G16),
            (Line.E2, Line.F1, Line.G12),
            (Line.E3, Line.G45, Line.F6, Line.G13, Line.G36, Line.G26),
            (Line.E4, Line.G46, Line.G25, Line.G14, Line.G35, Line.F5),
            (Line.E5, Line.G56, Line.G24, Line.G15, Line.G34, Line.F4),
        ],
    )
    eight = (
        "2, 4^{-1}, 8",
        "8A",
        "C_{20}",
        [
            (
                Line.E1,
                Line.F4,
                Line.G34,
                Line.G26,
                Line.G13,
                Line.G46,
                Line.E4,
                Line.F2,
            ),
            (
                Line.E2,
                Line.G56,
                Line.G35,
                Line.F1,
                Line.G23,
                Line.F5,
                Line.E5,
                Line.G16,
            ),
            (
                Line.E3,
                Line.G15,
                Line.G45,
                Line.G25,
                Line.F6,
                Line.G24,
                Line.G12,
                Line.G14,
            ),
            (Line.E6, Line.F3),
        ],
    )
    nine = (
        "3^{-1}, 9",
        "9A/9B",
        "C_{14}",
        [
            (
                Line.E1,
                Line.F2,
                Line.E3,
                Line.F6,
                Line.G26,
                Line.G35,
                Line.G16,
                Line.E6,
                Line.F5,
            ),
            (
                Line.E2,
                Line.G14,
                Line.G24,
                Line.F1,
                Line.G56,
                Line.G15,
                Line.G12,
                Line.G23,
                Line.G36,
            ),
            (
                Line.E4,
                Line.G13,
                Line.E5,
                Line.G34,
                Line.G46,
                Line.G45,
                Line.F3,
                Line.G25,
                Line.F4,
            ),
        ],
    )
    ten = (
        "1^{-1}, 2, 5",
        "10A",
        "C_{25}",
        [
            (Line.E1, Line.G25, Line.E3, Line.G26, Line.G24),
            (Line.E2, Line.F4, Line.G14, Line.G36, Line.F6),
            (
                Line.E4,
                Line.F3,
                Line.E5,
                Line.F1,
                Line.E6,
                Line.G56,
                Line.G12,
                Line.G46,
                Line.G23,
                Line.G45,
            ),
            (Line.F2, Line.G13),
            (Line.F5, Line.G34, Line.G35, Line.G15, Line.G16),
        ],
    )
    twelve_a = (
        "1^{-1}, 2, 3, 4^{-1}, 6^{-1}, 12",
        "12A/12B",
        "C_{13}",
        [
            (
                Line.E1,
                Line.E5,
                Line.G14,
                Line.G15,
                Line.G56,
                Line.G26,
                Line.G24,
                Line.E6,
                Line.E2,
                Line.G16,
                Line.F3,
                Line.G25,
            ),
            (Line.E4, Line.G46, Line.G12, Line.G45),
            (Line.F1, Line.G23, Line.G34, Line.G13, Line.F2, Line.F4),
            (Line.F5, Line.F6, Line.G35, Line.G36),
        ],
    )
    twelve_b = (
        "1, 2^{-1}, 3^{-1}, 4, 6",
        "12C",
        "C_{24}",
        [
            (
                Line.E1,
                Line.G23,
                Line.G34,
                Line.G36,
                Line.F5,
                Line.F2,
                Line.G16,
                Line.F3,
                Line.G15,
                Line.E3,
                Line.G25,
                Line.E6,
            ),
            (Line.E2, Line.G26, Line.F6),
            (
                Line.E4,
                Line.G24,
                Line.G35,
                Line.E5,
                Line.F1,
                Line.G13,
                Line.G46,
                Line.F4,
                Line.G14,
                Line.G56,
                Line.G12,
                Line.G45,
            ),
        ],
    )


class IrreducibleRepresentation(Enum):
    def __init__(
        self,
        me: str,
        frame: str,
        atlas: Optional[str],
        carter: str,
        character_on_1a2a2c: tuple[int, int, int],
    ) -> None:
        self.me = me
        self.frame = frame
        self.atlas = atlas
        self.carter = carter
        self.character_on_1a2a2c = character_on_1a2a2c

    p1 = ("V_1", "1_p", "\\chi_1", "\\phi_{1, 0}", (1, 1, 1))
    p6 = ("V_6", "6_p", "\\chi_4", "\\phi_{6, 1}", (6, -2, 4))
    p15 = ("V_{15, 1}", "15_p", "\\chi_7", "\\phi_{15, 5}", (15, -1, 5))
    q15 = ("V_{15, 2}", "15_q", "\\chi_8", "\\phi_{15, 4}", (15, 7, 5))
    p20 = ("V_{20}", "20_p", "\\chi_9", "\\phi_{20, 2}", (20, 4, 10))
    p24 = ("V_{24}", "24_p", "\\chi_{10}", "\\phi_{24, 6}", (24, 8, 4))
    p30 = ("V_{30}", "30_p", "\\chi_{11}", "\\phi_{30, 3}", (30, -10, 10))
    p60 = ("V_{60}", "60_p", "\\chi_{18}", "\\phi_{60, 5}", (60, -4, 10))
    p64 = ("V_{64}", "64_p", "\\chi_{19}", "\\phi_{64, 4}", (64, 0, 16))
    p81 = ("V_{81}", "81_p", "\\chi_{20}", "\\phi_{81, 6}", (81, 9, 9))

    n1 = ("V_1'", "1_n", None, "\\phi_{1, 36}", (1, 1, -1))
    n6 = ("V_6'", "6_n", None, "\\phi_{6, 25}", (6, -2, -4))
    n15 = ("V_{15, 1}'", "15_n", None, "\\phi_{15, 17}", (15, -1, -5))
    m15 = ("V_{15, 2}'", "15_m", None, "\\phi_{15, 16}", (15, 7, -5))
    n20 = ("V_{20}'", "20_n", None, "\\phi_{20, 20}", (20, 4, -10))
    n24 = ("V_{24}'", "24_n", None, "\\phi_{24, 12}", (24, 8, -4))
    n30 = ("V_{30}'", "30_n", None, "\\phi_{30, 15}", (30, -10, -10))
    n60 = ("V_{60}'", "60_n", None, "\\phi_{60, 11}", (60, -4, -10))
    n64 = ("V_{64}'", "64_n", None, "\\phi_{64, 13}", (64, 0, -16))
    n81 = ("V_{81}'", "81_n", None, "\\phi_{81, 10}", (81, 9, -9))

    s10 = ("U_{10}", "10_s", "\\chi_2 + \\chi_3", "\\phi_{10, 9}", (10, -6, 0))
    s20 = ("U_{20}", "20_s", "\\chi_5 + \\chi_6", "\\phi_{20, 10}", (20, 4, 0))
    s60 = (
        "U_{60}",
        "60_s",
        "\\chi_{12} + \\chi_{13}",
        "\\phi_{60, 8}",
        (60, 12, 0),
    )
    s80 = (
        "U_{80}",
        "80_s",
        "\\chi_{14} + \\chi_{15}",
        "\\phi_{80, 7}",
        (80, -16, 0),
    )
    s90 = (
        "U_{90}",
        "90_s",
        "\\chi_{16} + \\chi_{17}",
        "\\phi_{90, 8}",
        (90, -6, 0),
    )

    def notation(self, convention: str) -> str:
        if convention == "GAP":
            return str(self.gap_index)
        if convention == "Frame":
            return self.frame
        if convention == "Carter":
            return self.carter
        return self.me

    @staticmethod
    @functools.cache
    def from_character_on_1a2a2c(
        character: tuple[int, int, int]
    ) -> "IrreducibleRepresentation":
        for irreducible in IrreducibleRepresentation:
            if irreducible.character_on_1a2a2c == character:
                return irreducible


class CubicSurfaceWeylGroup:
    sigma12 = [
        (Line.E1, Line.E2),
        (Line.F1, Line.F2),
        (Line.G13, Line.G23),
        (Line.G14, Line.G24),
        (Line.G15, Line.G25),
        (Line.G16, Line.G26),
    ]
    cycle16 = [
        (Line.E1, Line.E2, Line.E3, Line.E4, Line.E5, Line.E6),
        (Line.F1, Line.F2, Line.F3, Line.F4, Line.F5, Line.F6),
        (Line.G12, Line.G23, Line.G34, Line.G45, Line.G56, Line.G16),
        (Line.G13, Line.G24, Line.G35, Line.G46, Line.G15, Line.G26),
        (Line.G14, Line.G25, Line.G36),
    ]
    cremona = [
        (Line.E1, Line.G23),
        (Line.E2, Line.G13),
        (Line.E3, Line.G12),
        (Line.F4, Line.G56),
        (Line.F5, Line.G46),
        (Line.F6, Line.G45),
    ]

    def __init__(self, **kwargs) -> None:

        super().__init__(**kwargs)
        self.group = PermutationGroup(
            gens=[
                CubicSurfaceWeylGroup.sigma12,
                CubicSurfaceWeylGroup.cycle16,
                CubicSurfaceWeylGroup.cremona,
            ],
            domain=Line,
        )
        self.order = self.group.order()
        print("Initialized group")
        self._irreducible_characters = self._initialize_irreducible_characters()
        print("Matched up irreducible characters")
        print("Computed characteristic characters")

    @functools.cache
    def representative(self, conjugacy_class: ConjugacyClass):
        return self.group(conjugacy_class.representative)

    @functools.cache
    def conjugacy_class(self, name: ConjugacyClass):
        return self.representative(name).conjugacy_class()

    @functools.cache
    def conjugacy_class_size(self, conjugacy_class: ConjugacyClass) -> int:
        return len(self.conjugacy_class(conjugacy_class))

    def _character_on_1a2a2c(self, character) -> tuple:
        return tuple(
            character(self.representative(conjugacy_class))
            for conjugacy_class in (
                ConjugacyClass.identity,
                ConjugacyClass.two_a,
                ConjugacyClass.two_c,
            )
        )

    def _initialize_irreducible_characters(
        self,
    ) -> dict[IrreducibleRepresentation, ClassFunction]:
        irreducible_characters = self.group.irreducible_characters()
        return {
            IrreducibleRepresentation.from_character_on_1a2a2c(
                self._character_on_1a2a2c(character)
            ): character  # TODO: make into class function
            for character in irreducible_characters
        }

    def character(self, irreducible: IrreducibleRepresentation):
        return self._irreducible_characters[irreducible]

    @functools.cache
    def character_table(
        self,
        irreducible_representation: IrreducibleRepresentation,
        conjugacy_class: ConjugacyClass,
    ) -> int:
        return self.character(irreducible_representation)(
            self.representative(conjugacy_class)
        )

    @functools.cache
    def characteristic_character(self, conjugacy_class: ConjugacyClass):
        return non_empty_sum(
            (
                self.character_table(irreducible_representation, conjugacy_class)
                * self.conjugacy_class_size(conjugacy_class)
                / self.order
            )
            * self.character(irreducible_representation)
            for irreducible_representation in IrreducibleRepresentation
        )

    def decompose(self, character, convention: str = "Frame") -> str:
        strings = []
        for irreducible_representation in IrreducibleRepresentation:
            multiplicity = self.character(irreducible_representation).scalar_product(
                character
            )
            if multiplicity == 0:
                continue
            notation = irreducible_representation.notation(convention)
            if multiplicity != 1:
                strings.append(f"{notation}^{{\\oplus{multiplicity}}}")
            else:
                strings.append(f"{notation}")
        return f"${' + '.join(strings)}$"

    def character_from_decomposition(self, terms: Iterable[IrreducibleRepresentation]):
        return non_empty_sum(self.character(name) for name in terms)

    def count_cosets_fixed_by_conjugacy_class(
        self, subgroup, conjugacy_class: ConjugacyClass
    ) -> int:
        conjugacy_class_elements = self.conjugacy_class(conjugacy_class)
        intersection = set(subgroup) & set(conjugacy_class_elements)
        return (len(intersection) * self.order) / (
            len(conjugacy_class_elements) * len(subgroup)
        )

    def stabilizer_subgroup(self, pattern: Iterable[Line], ordered: bool = False):
        if ordered:
            subgroup = set(self.group)
            for line in pattern:
                subgroup = {g for g in subgroup if g(line) == line}
            subgroup = self.group.subgroup(subgroup)
        else:
            subgroup = self.group.stabilizer(pattern, "OnSets")
        return subgroup


class Clebsch:
    phi = (sqrt(5) + 1) / 2

    def __init__(
        self, default_color=Color("black"), highlight_color=Color("orange"), **kwargs
    ) -> None:
        super().__init__(**kwargs)

        self.default_color = default_color
        self.highlight_color = highlight_color

        self.x, self.y, self.z = x, y, z = var("x,y,z")
        self.plot = Graphics()
        r = self.r = 16
        self.plot += implicit_plot3d(
            8 * (x ** 3 + y ** 3 + z ** 3)
            + (8 - (x + y + z)) ** 3
            - (8 + x + y + z) ** 3,
            (x, -r, r),
            (y, -r, r),
            (z, -r, r),
            opacity=1,
        )
        phi = Clebsch.phi
        points_on_clebsch_lines = {
            Line.E1: [
                (-r, 4 * (phi - 1) + r * phi / 2, -4 * (phi - 1) + r * phi / 2),
                (r, 4 * (phi - 1) - r * phi / 2, -4 * (phi - 1) - r * phi / 2),
            ],
            Line.E2: [
                (4 * (phi - 1) + r * phi / 2, -4 * (phi - 1) + r * phi / 2, -r),
                (4 * (phi - 1) - r * phi / 2, -4 * (phi - 1) - r * phi / 2, r),
            ],
            Line.E3: [
                (-4 * (phi - 1) + r * phi / 2, -r, 4 * (phi - 1) + r * phi / 2),
                (-4 * (phi - 1) - r * phi / 2, r, 4 * (phi - 1) - r * phi / 2),
            ],
            Line.E4: [
                (-4 * phi - r * (phi - 1) / 2, -r, 4 * phi - r * (phi - 1) / 2),
                (-4 * phi + r * (phi - 1) / 2, r, 4 * phi + r * (phi - 1) / 2),
            ],
            Line.E5: [
                (-r, 4 * phi - r * (phi - 1) / 2, -4 * phi - r * (phi - 1) / 2),
                (r, 4 * phi + r * (phi - 1) / 2, -4 * phi + r * (phi - 1) / 2),
            ],
            Line.E6: [
                (4 * phi - r * (phi - 1) / 2, -4 * phi - r * (phi - 1) / 2, -r),
                (4 * phi + r * (phi - 1) / 2, -4 * phi + r * (phi - 1) / 2, r),
            ],
            Line.F1: [
                (-r, -4 * phi - r * (phi - 1) / 2, 4 * phi - r * (phi - 1) / 2),
                (r, -4 * phi + r * (phi - 1) / 2, 4 * phi + r * (phi - 1) / 2),
            ],
            Line.F2: [
                (-4 * phi - r * (phi - 1) / 2, 4 * phi - r * (phi - 1) / 2, -r),
                (-4 * phi + r * (phi - 1) / 2, 4 * phi + r * (phi - 1) / 2, r),
            ],
            Line.F3: [
                (4 * phi - r * (phi - 1) / 2, -r, -4 * phi - r * (phi - 1) / 2),
                (4 * phi + r * (phi - 1) / 2, r, -4 * phi + r * (phi - 1) / 2),
            ],
            Line.F4: [
                (4 * (phi - 1) + r * phi / 2, -r, -4 * (phi - 1) + r * phi / 2),
                (4 * (phi - 1) - r * phi / 2, r, -4 * (phi - 1) - r * phi / 2),
            ],
            Line.F5: [
                (-r, -4 * (phi - 1) + r * phi / 2, 4 * (phi - 1) + r * phi / 2),
                (r, -4 * (phi - 1) - r * phi / 2, 4 * (phi - 1) - r * phi / 2),
            ],
            Line.F6: [
                (-4 * (phi - 1) + r * phi / 2, 4 * (phi - 1) + r * phi / 2, -r),
                (-4 * (phi - 1) - r * phi / 2, 4 * (phi - 1) - r * phi / 2, r),
            ],
            Line.G12: [(r, 0, r - 8), (8 - r, 0, -r)],
            Line.G13: [(r - 8, r, 0), (-r, 8 - r, 0)],
            Line.G14: [(r, -r, 8), (-r, r, 8)],
            Line.G15: [(0, r, -r), (0, -r, r)],
            Line.G16: [(-r, -8, r), (r, -8, -r)],
            Line.G23: [(0, r - 8, r), (0, -r, 8 - r)],
            Line.G24: [(-8, -r, r), (-8, r, -r)],
            Line.G25: [(r, 8, -r), (-r, 8, r)],
            Line.G26: [(r, -r, 0), (-r, r, 0)],
            Line.G34: [(r, 0, -r), (-r, 0, r)],
            Line.G35: [(-r, r, -8), (r, -r, -8)],
            Line.G36: [(8, r, -r), (8, -r, r)],
            Line.G45: [(r, r - 8, 0), (8 - r, -r, 0)],
            Line.G46: [(0, r, r - 8), (0, 8 - r, -r)],
            Line.G56: [(r - 8, 0, r), (-r, 0, 8 - r)],
        }

        self._lines_on_clebsch = {
            line: line3d(points, thickness=3, color=default_color)
            for line, points in points_on_clebsch_lines.items()
        }

        for line in Line:
            self.plot += self._lines_on_clebsch[line]

    def highlight_pattern(self, pattern: Collection[Line] = Line) -> None:
        for line, line_plot in self._lines_on_clebsch.items():
            if line in pattern:
                line_plot.texture.color = self.highlight_color
            else:
                line_plot.texture.color = self.default_color


class CubicStatistics(CubicSurfaceWeylGroup, Clebsch):

    cover_cohomology_decompositions = [
        [IrreducibleRepresentation.p1],
        [IrreducibleRepresentation.q15],
        [IrreducibleRepresentation.p81],
        [
            IrreducibleRepresentation.p15,
            IrreducibleRepresentation.s80,
            IrreducibleRepresentation.s90,
        ],
        [
            IrreducibleRepresentation.p30,
            IrreducibleRepresentation.n30,
            IrreducibleRepresentation.s80,
            IrreducibleRepresentation.s10,
        ],
    ]

    q = var("q")
    pgl4_point_count = (q ** 6) * (q ** 4 - 1) * (q ** 3 - 1) * (q ** 2 - 1)

    def __init__(self, **kwargs) -> None:
        super().__init__(**kwargs)

        self.cover_cohomology_characters = [
            self.character_from_decomposition(decomposition)
            for decomposition in CubicStatistics.cover_cohomology_decompositions
        ]
        self.total_moduli_space_frequency = sum(
            self.frequency(conjugacy_class) for conjugacy_class in ConjugacyClass
        )
        print("Counted frequencies by conjugacy class")

        self.clebsch = Clebsch()
        print("Plotted Clebsch cubic with lines")
        print("Done!")

    @functools.cache
    def frequency(self, conjugacy_class: ConjugacyClass) -> int:
        return sum(
            (
                (-1) ** i
                * CubicStatistics.q ** (4 - i)
                * Rational(
                    character.scalar_product(
                        self.characteristic_character(conjugacy_class)
                    )
                )
            )
            for i, character in enumerate(self.cover_cohomology_characters)
        )

    def coset_frequencies(self, subgroup) -> dict[int, Any]:
        ret = defaultdict(int)
        for conjugacy_class in ConjugacyClass:
            cosets_fixed_by_class = self.count_cosets_fixed_by_conjugacy_class(
                subgroup, conjugacy_class
            )
            ret[cosets_fixed_by_class] += self.frequency(conjugacy_class)
        return ret

    def pattern_frequencies(
        self, pattern: Iterable[Line], ordered: bool = False
    ) -> dict[int, Any]:
        return self.coset_frequencies(self.stabilizer_subgroup(pattern, ordered))

    def total_occurrences(self, lines: Iterable[Line], ordered: bool = False):
        return sum(
            cosets * frequency
            for cosets, frequency in self.pattern_frequencies(lines, ordered).items()
        )

    def pattern_table(self, pattern: Iterable[Line], ordered: bool = False, q_value=q):
        return table(
            rows=self.collate_pattern(pattern, ordered, q_value),
            header_row=[
                "Number of occurrences",
                "Frequency",
                "Asymptotic as $q \\to \\infty$",
            ],
            align="right",
            header_column=True,
        )

    def collate_pattern(
        self, pattern: Iterable[Line], ordered: bool = False, q_value=q
    ):
        frequencies_dict = self.pattern_frequencies(pattern, ordered)
        relative_frequencies = {
            count: (frequency / self.total_moduli_space_frequency)(q=q_value)
            for count, frequency in frequencies_dict.items()
        }
        average = sum(
            count * frequency for count, frequency in relative_frequencies.items()
        )
        if q_value == CubicStatistics.q:
            relative_frequencies_list = [
                [
                    count,
                    frequency.simplify_rational(),
                    frequencies_dict[count].leading_coefficient(CubicStatistics.q),
                ]
                for count, frequency in sorted(relative_frequencies.items())
            ]
            relative_frequencies_list.append(
                [
                    "Average",
                    average.simplify_rational(),
                    average.numerator().leading_coefficient(CubicStatistics.q)
                    / average.denominator().leading_coefficient(CubicStatistics.q),
                ]
            )
        else:
            relative_frequencies_list = [
                [count, frequency, rational_to_decimal(frequency)]
                for count, frequency in sorted(relative_frequencies.items())
            ]
            relative_frequencies_list.append(
                ["Average", average, rational_to_decimal(average)]
            )
        return relative_frequencies_list


T = TypeVar("T")


def rational_to_decimal(number: int) -> str:
    return f"${n(number):.7}\\dots$"


def non_empty_sum(iterable: Iterable[T]) -> T:
    s = list(iterable)
    if not s:
        raise IndexError("Can only sum at least one term")
    ret = s[0]
    for term in s[1:]:
        ret += term
    return ret


if __name__ == "__main__":
    cubic_statistics = CubicStatistics()
