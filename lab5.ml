(*
                              CS51 Lab 5
           Variants, algebraic types, and pattern matching
 *)

(*
Objective:

In this lab you'll practice concepts of algebraic data types,
including product types (like tuples) and sum types (like variants),
and the expressive power that arises from combining both. A theme will
be the requirement of and checking for consistency with invariants.

NOTE: Since we ask that you define types in this lab, you must
complete certain exercises before this will compile with the testing
framework on the course grading server. Exercises 1, 2, 6, and 9 are
required for full compilation.

 *)

(*==============================================================================
Part 1: Colors as an algebraic data type

In this lab you'll use algebraic data types to create several data
structures.

Ultimately, you'll define several types and structures that allow you
to create a family tree. To do this, you need to create a type to
store a set of biographical information about a person, like
name, birthdate, and favorite color. This set of data is
different from the enrollment data from the prior lab, so you'll need
to create a new type.

You might be tempted to do something simple like

  type person = { name : string;
                  favorite : string;
                  birthday : string } ;;

Let's consider why this may not be appropriate by evaluating the type
for each record field individually.

First, it seems reasonable for a name to be a string, so let's declare
that complete and move on.

The "favorite" field is more problematic. Although we named it such
for simplicity, it doesn't convey very well that we intended for this
field to represent a person's favorite *color*. This could be resolved
with some documentation, but is not enforced at any level other than
hope. Next, it's very likely that many persons would select one of a
subset of colors. Let's fix this issue first.

........................................................................
Exercise 1: Define a new type, called "color_label", whose value can
be any of the following options: red, crimson, orange, yellow, green,
blue, indigo, or violet.
......................................................................*)

type color_label =
  | Red
  | Crimson
  | Orange
  | Yellow
  | Green
  | Blue
  | Indigo
  | Violet ;;

(* But this is an overly simple representation of colors. Let's make
it more usable.

One of the most commonly used methods of representing color in digital
devices is as an "RGB" value: a triplet of values to represent red,
green, and blue components that, through additive mixing, produce the
wide array of colors our devices render.

Commonly, each of the red, green, and blue values are made up of a
single 8-bit (1-byte) integer. Since one byte represents 256 discrete
values, there are over 16.7 million (256 * 256 * 256) possible colors
that can be represented with this method.

The three components that make up an RGB color are referred to as
"channels". In this 8-bit-per-channel model, a value of 0 represents
no color and a value of 255 represents the full intensity of that
color. Some examples:

     R  |  G  |  B  | Color
    ----|-----|-----|------------
    255 |   0 |   0 | Red
      0 |  64 |   0 | Dark green
      0 | 255 | 255 | Cyan
    164 |  16 |  52 | Crimson


........................................................................
Exercise 2: Define a color type that supports either "Simple" colors
(from the color_label type you defined previously) or "RGB" colors,
which would incorporate a tuple of values for the three color
channels. You'll want to use Simple and RGB as the value constructors
in this new variant type.
......................................................................*)

type color =
  | Simple of color_label
  | RGB of int * int * int ;;

(* There is an important assumption about the RGB values that
determine whether a color is valid or not. The RGB type presupposes an
*invariant*, that is, a condition that we assume to be true in order
for the type to be valid.

- The red, green, and blue channels must be a non-negative
  8-bit int. Therefore, each channel must be in the range [0, 255].

Since OCaml, unlike some other languages, does not have native support
for unsigned 8-bit integers, you should ensure the invariant remains
true in your code. (You might think to use the OCaml "char" type --
which is an 8-bit character -- but this would be an abuse of the
type. In any case, thinking about invariants will be useful practice
for upcoming problem sets.)

We'll want a function to validate the invariant for RGB color
values. There are several approaches to building such functions,
which differ in their types, and for which we'll use different naming
conventions:

* valid_rgb : color -> bool -- Returns true if the color argument
  is valid, false otherwise.

* validated_rgb : color -> color -- Returns its argument unchanged if
  it is a valid color, and raises an appropriate exception otherwise.

* validate_rgb : color -> unit -- Returns unit; raises an appropriate
  exception if its argument is not a valid color.

The name prefixes "valid_", "validated_", and "validate_" are intended
to be indicative of the different approaches to validation.

In this lab, we'll use the "validated_" approach and naming
convention, though you may want to think about the alternatives. In
the next lab, we use the "valid_" alternative.

........................................................................
Exercise 3: Write a function, validated_rgb, that accepts a color and
returns that color unchanged if it's valid. However, if its argument
is not a valid color (that is, the invariant is violated), it raises
an Invalid_color exception with a useful message.
......................................................................*)

exception Invalid_color of string ;;

let validated_rgb (c : color) : color =
  let bad (x : int) : bool = (x < 0 || x > 255) in
  match c with
  | Simple x -> c
  | RGB (r, g, b) ->
    if bad r then raise (Invalid_color "bad red channel")
    else if bad g then raise (Invalid_color "bad green channel")
    else if bad b then raise (Invalid_color "bad blue channel")
    else c ;;

(*......................................................................
Exercise 4: Write a function, make_color, that accepts three integers
for the channel values and returns a value of the color type. Be sure
to verify the invariant.
......................................................................*)

let make_color (r : int) (g : int) (b : int) : color =
  validated_rgb (RGB (r, g, b)) ;;

(*......................................................................
Exercise 5: Write a function, convert_to_rgb, that accepts a color and
returns a 3-tuple of ints representing that color. This is trivial for
RGB colors, but not quite so easy for the hard-coded Simple colors.
We've already provided some RGB values for simple colors above, and
below are some other values you might find helpful.

     R  |  G  |  B  | Color
    ----|-----|-----|--------
    255 | 165 |   0 | Orange
    255 | 255 |   0 | Yellow
     75 |   0 | 130 | Indigo
    240 | 130 | 240 | Violet
......................................................................*)

let convert_to_rgb (c : color) : int * int * int =
  match c with
  | RGB (r, g, b) -> (r, g, b)
  | Simple x ->match x with
    | Red ->     (255,   0,   0)
    | Crimson -> (164,  16,  52)
    | Orange ->  (255, 165,   0)
    | Yellow ->  (255, 255,   0)
    | Green ->   (  0, 255,   0)
    | Blue ->    (  0,   0, 255)
    | Indigo ->  ( 75,   0, 130)
    | Violet ->  (240, 130, 240) ;;

(*======================================================================
Part 2: Dates as a record type

Now let's move on to the last data type that will be used in the
biographical data type: the date field.

Above, we naively proposed a string for the date field. Does this make
sense for this field? Arguably not, since it will make comparison and
calculation very difficult.

Dates are frequently needed data in programming, and OCaml (like many
languages) supports them through a library module, named "Date".
Normally, we would reduce duplication of code by relying on that
module, but for the sake of practice you'll develop your own simple
version.

........................................................................
Exercise 6: Create a type, called "date", that supports values for
years, months, and days. First, consider what types of data each value
should be. Then, consider the implications of representing the overall
data type as a tuple or a record.
......................................................................*)

type date = { year : int; month : int; day : int };;

(* After you've thought it through, look up the Date module in the
OCaml documentation to see how this was implemented there. If you
picked differently, why did you choose that way? Why might the Date
module have implemented this data type as it did?

........................................................................
Exercise 7: Change your data type, above, to implement it in a manner
identical to the Date module, but only with fields for year, month, and
day. If no changes are required...well, that was easy.
........................................................................

Like the color type, above, the date object has invariants. In fact,
the invariants for this type are more complex: we must ensure that
"days" fall within an allowable range depending on the month, and even
on the year.

The invariants are as follows:

- For our purposes, we'll only support positive years.

- January, March, May, July, August, October, and December have 31
  days.

- April, June, September, and November have 30 days.

- February has 28 days in common years, 29 days in leap years.

- Leap years are years that can be divided by 4, but not by 100,
  unless by 400.

You may find Wikipedia's leap year algorithm pseudocode useful:
https://en.wikipedia.org/wiki/Leap_year#Algorithm

........................................................................
Exercise 8: Create a validated_date function that raises Invalid_date if
the invariant is violated, and returns the date if valid.
......................................................................*)

exception Invalid_date of string ;;

let validated_date ({year; month; day} as date) : date =
  if year < 0 then raise (Invalid_date "negative year")
  else
    let leap = (year mod 4 = 0 && year mod 100 <> 0)|| year mod 400 = 0 in
    let max_days =
      match month with
      | 1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
      | 4 | 6 | 9 | 11 -> 30
      | 2 -> if leap then 29 else 28
      | _ -> raise (Invalid_date "bad month") in
    if day > max_days then raise (Invalid_date "day too large")
    else if day < 1 then raise (Invalid_date "day too small")
    else date ;;

(*======================================================================
Part 3: Family trees as an algebraic data type

Now, combine all of these different types to define a person record,
with a "name", a "favorite" color, and a "birthdate".

........................................................................
Exercise 9: Define a person record type. Use the field names "name",
"favorite", and "birthdate".
......................................................................*)

type person = { name : string; favorite : color; birthdate : date } ;;

(* Let's now do something with these person values. We'll create a
data structure that allows us to model simple familial relationships.

This family tree will be a data structure that shows the familial
status of persons. A family can be one of three variants for this
simple implementation:

1. An unmarried person with no children.
2. A married person.
3. A family made up of two married parents and some number of children.

(For simplicity, we postpone consideration of other familial structures.)

An easy mistake is to directly translate this to the following structure:

type family =
  | Single of person
  | Married of person * person
  | Family of person * person * family list ;;

But do we need to make the distinction between Married and a Family with
an empty list of children? Arguably, the latter corresponds to the former,
so we can remove that from the structure for these problems: *)

type family =
  | Single of person
  | Family of person * person * family list ;;

(* Let's now write a series of functions to build these family trees.

........................................................................
Exercise 10: Write a function that accepts a name, a color, and a date,
and returns a Single. If you completed the validity functions that
ensure the invariants are preserved for color and date, use them here
as well.
......................................................................*)

let new_child (name : string) (col : color) (birth : date) : family =
  Single { name;
           favorite = validated_rgb col;
           birthdate = validated_date birth } ;;

(*......................................................................
Exercise 11: Write a function that allows a person to marry in to a
family, by accepting a family and a person, and returning a new and
enlarged family. How should this behave in the event that the family
is already made up of a married couple?
......................................................................*)

exception Family_Trouble of string ;;

let marry (fam : family) (spouse : person) : family =
  match fam with
  | Single per -> Family (per, spouse, [])
  | Family _ -> raise (Family_Trouble ("cannot add "
                                       ^ spouse.name ^ " to a couple")) ;;

(*......................................................................
Exercise 12: Write a function that accepts two families, and returns
an enlarged family with the second family added as a child of the
first. Note that this allows the addition of a single child to a
family, but also allows the general case. Consider the implicit
assumptions provided in the type definition of family to determine how
to behave in corner cases.
......................................................................*)

let add_to_family (fam : family) (child : family) : family =
  match fam with
  | Single _ -> raise (Family_Trouble "singles don't have children")
  | Family (p1, p2, children) -> Family (p1, p2, child :: children) ;;

(*......................................................................
Exercise 13: Complete the function below that counts the number of
people in a given family. Be sure you count all spouses and children.
......................................................................*)

let rec count_people (fam: family) : int =
  match fam with
  | Single _ -> 1
  | Family (_, _, c) -> 2 + List.fold_left (+) 0(List.map count_people c) ;;


