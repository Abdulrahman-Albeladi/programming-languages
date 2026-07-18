"""Simple in-memory roster models for people, students, and staff."""


class Person:
    """A person identified by a name and age."""

    def __init__(self, name, age):
        self.name = name
        self.age = age

    def get_age(self):
        return self.age

    def set_age(self, age):
        self.age = age
        return self


class Student(Person):
    """A person enrolled with a grade."""

    def __init__(self, name, age, grade):
        super().__init__(name, age)
        self.grade = grade

    def get_grade(self):
        return self.grade

    def change_grade(self, grade):
        self.grade = grade
        return self


class Staff(Person):
    """A person employed in a staff position."""

    def __init__(self, name, age, position):
        super().__init__(name, age)
        self.position = position

    def get_position(self):
        return self.position

    def change_position(self, position):
        self.position = position
        return self


class Roster:
    """An in-memory collection of ``Person`` instances."""

    def __init__(self):
        self.people = []

    def add(self, person):
        """Add a person to the roster when it is a supported record type."""
        if isinstance(person, Person):
            self.people.append(person)

    def size(self):
        return len(self.people)

    def remove(self, person):
        """Remove a person from the roster when present."""
        if person in self.people:
            self.people.remove(person)

    def get_person(self, name):
        """Return the first person with the requested name, if any."""
        for person in self.people:
            if person.name == name:
                return person
        return None

    def map(self, func):
        """Apply ``func`` to each person in the roster."""
        for person in self.people:
            func(person)
