filterops.vim
---
Easy text filter operators

Author: Jo Totland\
Version: 1.0

Introduction
---

This plugin adds some useful helpers to create operator mappings/visual
mappings, building on top of operatorfunc. Instead of the low-level interface
offered by native Vim, they operate by "filtering" lines of text, with the
result of the filtering function (or command) replacing the original text.

In addition, it defines three useful vim operator mappings.


Yank to visible terminals
---

    <plug>(yank-to-visible-terminals)
    <plug>(yank-line-to-visible-terminals)
    yt{motion}
    ytt
    {Visual}gyt


These operator/visual mode mappings will yank the text to any Vim8 or Neovim
terminals that is visible on screen. A newline is added if necessary. If no
terminals are visible on the screen, nothing happens.


If you have some terminals you want to skip, even if they are visible on the
screen, you can set a buffer variable:

    let b:yank_to_visible_terminals_skip_this = 1

If you want to send text to all the visible terminals directly, without first
having to write it in a buffer, you can use the command :YT

Yank vimscript 
---

    <plug>(yank-vimscript)
    <plug>(yank-vimscript-line)
    yv{motion}
    yvv
    {Visual}gyv

These operator/visual mode mappings will evaluate the text they operate upon as
vimscript. (With the limitation that if the vimscript needs to be evaluated in
a special context, such as for autoloaded functions, they will not work as
intended).


Filter through external command
---

    <plug>(filter)
    <plug>(filter-line)
    !{motion}{command}
    !!{command}
    {Visual}!

These operators or visual mode mappings are intended as a better alternative to
the built-in !-mapping. 

(The built-in ! mapping only functions line-wise. These alternative mappings
work with any kind of selection or text object, even blockwise. So if you want
to use an external command to sort a rectangular selection, now it can be done. 


The FilterMap command
---

    :FilterMap {opmap} {linemap} {vmap} {funcref-or-quoted-command}

FilterMap hides the arcane syntax needed to create the three different
mappings, one for the operator, one for visual mode, and one for operating
linewise, using the machinery explained further below. 

Ideally, you should not need to know much else to create functioning new
operator/visual mappings. 

FilterMap takes four arguments: the operator mapping, the linewise mapping, the
visual mapping, and finally the function or external command to be run on the
text selected by the movement, text-operator or visual selection.


Example mapping with external command
---

If you want to write an operator for sorting lines using the external command
"sort", here's a simple example:

    FilterMap \s \ss \s "sort"

This defines three mappings:

`\s{motion}` sorts text by {motion} (which can be a text-object)

`\ss` sorts a single line. Not very useful by itself, but you can add a prefix
to sort more than one line. E.g. `5\ss` will sort the line under the cursor,
and four lines below it.

{Visual}`\s` sorts each line in the visual selection.

Example mapping with funcref
---

To illustrate Filtermap with a function instead of an external command, we
write an operator replacing any nonblank character with x:

    `FilterMap cx cxx gcx {l->map(l,{k,v->substitute(v,'\S','x','g')})}`

`cx`{motion} replaces nonblank letters in {motion} with x

`cxx` replaces nonblank letters on the current line with x.

{Visual}`gcx` replaces nonblank letters in selection with x.

Explanation: 

The funcref given to filtermap above is a lambda function. The function will
be called with a single argument `l`, a list of lines (each line is a string).

Wa pass `l` to `map()` together with a function. Map will execute the function
on each element of `l`, that is, on each line. Then map assembles the return
values of each function back into a list. This list is return value of `map()`
and therefore also of the outer lambda.

The function we pass to `map()` must take two arguments, the index k, and the
value v. Instead of a named function, we created another (inner) lambda. The
inner lambda uses substitute() to replace any nonblank character on the line
with an x.

In the example above we wrote the lambda-expression without spaces, to avoid
quoting problems with FilterMap. In a more typical scenario, you will write a
function, and pass a funcref to it, instead of just using lambda.


The machinery behind filtermap
---

    filterops#Filter(mode)
    g:FILTEROPS_FILTER

`filterops#Filter()` is a function that takes the text contained in the
motion, text-object or visual selection, runs it through the filter stored in
`g:FILTEROPS_FILTER`, and replaces the original text with the result of the
operation. 

If `g:FILTEROPS_FILTER` is a string, the selection or motion is piped through an
external command, and replaced with the output of that command.

If `g:FILTEROPS_FILTER` is a funcref, the selection or motion is passed to this
function as a list of lines, and replaced with the return value of the function
(which should also be a list of lines).

(A close analogue of `filterops#Filter()` and `g:FILTEROPS_FILTER` is the
built-in `g@` operator and `operatorfunc`).

Skipping default mappings
---
To skip default mappings, put in your vimrc:

    let g:filterops_no_default_maps = 1
