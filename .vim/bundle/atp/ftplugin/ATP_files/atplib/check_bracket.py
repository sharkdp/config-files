#!/usr/bin/env python
"""
Check if a bracket '(' is closed. Return the (line, col) of a not closed
bracket.
"""

__all__ = [ 'byte_pos', 'line_pos', 'check_bracket_frompos', 'check_bracket' ]

DEBUG = False

def byte_pos(text, line, col):
    """ Return position index of (line, col)
    line is line index, col is column index

    The returning byte position __includes__ all '\n's.

    Text is unicode.
    """

    if type(text) != list:
        lines = text.splitlines(True)[:line+1]
    else:
        lines = text[:line+1]
    b = len(''.join(lines[:line])) + len(lines[line][:col])
    return b

def line_pos(text, b):
    """ Return line, col position of byte b."""

    beg = text[:b]
    line = beg.count('\n')
    lines = text.splitlines(True)
    if line:
        col = b-byte_pos(text, line-1, len(lines[line-1])-1)-1
    else:
        col = b
    return (line, col)

def check_bracket_frompos(text, o_bra, c_bra, pos):
    """ Check if the bracket is closed, starting counting from pos (including).

    Return the idx of position where the bracket is closed or -1."""

    length = len(text)
    if pos >= length:
        return -1

    end = text[pos+1:]
    count_open = 1
    count_close = 0
    idx = pos
    if DEBUG:
        print("  >> count_open =  %d" % count_open)
    while idx < length:
        if text[idx:idx+len(o_bra)] == o_bra and (idx == 0 or text[idx-1] != "\\"):
            count_open +=1
        if text[idx:idx+len(c_bra)] == c_bra and (idx == 0 or text[idx-1] != "\\"):
            count_close +=1
        # if DEBUG:
            # print("  >> (%d,%s) (%d,%d)" % (idx, text[idx], count_open, count_close))
        if count_open == count_close:
            if DEBUG:
                print("  >> True; finished at (%d, %s)" % (idx, repr(text[idx])))
            return idx
        idx += 1
    else:
        if DEBUG:
            print("  >> False; finished at (%d, %s)" % (idx, repr(text[idx-1])))
        return -1

def check_bracket(text, line, col, bracket_dict):
    """ Return position of the first opened and not closed bracket before
    (line, col) [excluding]

    text    - text to search within
    line    - the line where to start (lines start count from 0)
    col     - the columnt where to start (columns start count from 0)
    bracket_dict - dictinoary of keys:values : '(' : ')'

    Returns triple (line, col, ket) - line, col position where ket was opened.
    """

    pos = byte_pos(text, line, col)
    beg = text[:pos+1] # don't exclude the curent byte

    stack = [] # Holds list of all brackets which are opened before the pos and not closed or closed after
               # the function returns the first position in this stack.


    found_closed = False
    o_count = 0
    x = pos
    while x >= 0:
        x -= 1

        o_cond = False
        c_cond = False
        if not found_closed:
            for (O_BRA, C_BRA) in bracket_dict.items():
                (o_bra, c_bra) = (O_BRA, C_BRA)
                if text[x:x+len(O_BRA)] == O_BRA and (x == 0 or text[x-1] != "\\"):
                    o_cond = True
                    if DEBUG:
                        lpos = line_pos(text, x)
                        print("-- o_cond: %d, (%d, %d), %s" % (x, lpos[0], lpos[1], O_BRA))
                    break
                elif text[x:x+len(C_BRA)] == C_BRA and (x == 0 or text[x-1] != "\\"):
                    c_cond = True
                    break
        else:
            if text[x:x+len(O_BRA)] == O_BRA and (x == 0 or text[x-1] != "\\"):
                o_cond = True
            for (o_bra, c_bra) in bracket_dict.items():
                if text[x:x+len(c_bra)] == c_bra and (x == 0 or text[x-1] != "\\"):
                    c_cond = True
                    break

        if o_cond:
            stack.append((x, O_BRA))
            if DEBUG:
                print("-- cbf args: (%s, %s, %d)" % (O_BRA, C_BRA, pos))
                print("-- (%d, %d)" % line_pos(text, pos))
            closed = check_bracket_frompos(text, O_BRA, C_BRA, pos)
            if DEBUG:
                print("-- closed: %s" % closed)
            if closed >= 0:
                pos = closed + 1
                if not found_closed:
                    # If we found closed bracket we cannot expect that in between there are other brackets.
                    # ( { ( X  )   - we should not close at X the opened { even if it is opened.
                    found_closed = True
            if DEBUG:
                print("-- (%d, %s)" % (x, O_BRA))
            if closed == -1:
                """ We can return here since we skip all the ' ( ... ) ' """
		lpos =line_pos(text, stack[0][0])
                if DEBUG:
                    pos = line_pos(text, x)
                    print("break at (%d,%d,%s)" % (pos[0], pos[1], text[x]))
                return (lpos[0], lpos[1], stack[0][1])
        elif c_cond:
            # Skip till the matching o_bra.

            s_x = x
            count_open = 0
            count_closed = 1

            # If the bracket is one of \), \}, \] jump to the matching one.
            if x and text[x-1] == "\\":
                backslash = True
            else:
                backslash = False

            while count_open != count_closed:
                """ We should modify the text here so it simplifies. This is
                might be important for check_bracket_atpos()
                """
                x -= 1
                t = beg[x]
                if text[x:x+len(o_bra)] == o_bra:
                    if backslash :
                        if x-1 and text[x-1] == "\\":
                            count_open += 1
                    else:
                        count_open += 1
                if text[x:x+len(c_bra)] == c_bra:
                    if backslash :
                        if x-1 and text[x-1] == "\\":
                            count_closed += 1
                    else:
                        count_closed += 1
                if x == 0:
                    # Ups. There was no matching (.
                    return (-1, -1, O_BRA)

            if DEBUG:
                print("Skipping `%s:%s` (%d,%s,%d,%s)." % (O_BRA, C_BRA, s_x, text[s_x], x, text[x]))
    return (-1, -1, '')

if __name__ == "__main__":

    """
    ==========
    Test suite
    ==========
    """



    test_1=u"""(
(
    test 1 [line-inedx: 3]
)
)
"""

    # before implementing the stack in check_bracket:
    test_2=u"""(<-considered as open
(<- considered as closed
    test 2 unclosed bracket
)
"""

    # after adding the stack in check_bracket:
    """I want the test two to return."""
    test_2a=u"""(<-considered as closed
(<- considered as open
        test 2 unclosed bracket
)
"""

    test_3=u"""(
( ) <- skip
(
       test 3 unclosed bracket with skipping
)
"""


    test_4=u"""(
( (  (  ) ) ) <- skip
(
       test 3 unclosed bracket with skipping
)
)
"""


    test_5=u"""(
[
(    {   }
HERE  we should close the round bracket. Now the algorithm returns the right
bracket but it stops at the square bracket two lines above.

should return 0, 0
)
    """

    test_6=u"""(
( [
LINE 2 should return -1, -1
]"""

    test_7=u"""(
    (
    )
    (
        (
        )
    )
X opened at 0

    (
        (
            (
            )
        )
    )
"""

    test_8=u"""
(--------)
(
X
{----}
)
-------
"""

    test_9=u"""(
\( (    \)
X
)"""

    test_10=u"""(
 {    }  (
X
)
"""

    test_11=u"""\\(
( )
X

"""

    test_12=u"""( \\(
  (  ) \\)
X
"""

    test_13=u"""( \\(
  (  )
X
\\)
"""

    test_14=u"""\\(
  (
X
)
"""

    real_test_1="""Now let us give a construction of a generalised quotient of
\(\mathcal{U}(\mathfrak{g})\). Let \(\pi:\mathfrak{g}\eir\mathfrak{h}\) be
a \(\k\)-linear quotient. Let \(\mathcal{U}(\mathfrak{h})\) be the quotient of
the free \(\mathcal{U}(\mathfrak{g})\)-module
\(\mathsf{F}(\k1\oplus\mathfrak{h})\) on \(\k1\oplus\mathfrak{h}\) by the
following relation:
\[1\cdot X = \pi(X)\]
for \(X\in\mathfrak{g}\). There is a right
\(\mathcal{U}(\mathfrak{g})\)-module homomorphism from
\(\mathcal{U}(\mathfrak{g})\) to \(\mathcal{U}(\mathfrak{n})\):
\[\mathcal{U}(\pi):\mathcal{U}(\mathfrak{g})\sir\mathcal{U}(\mathfrak{n})\]
which is uniquely determined by \(\mathcal{U}(\pi)(X)=\pi(X)\) for
\(X\in\mathfrak{g}\), where \(\pi(X)\in\mathfrak{h}\) is treated as an element
of \(\mathcal{U}(\mathfrak{h})\) and \(\mathcal{U}(\pi)(1)=1\). The map
\(\mathcal{U}(\pi)\) is well defined by the above Poincar\'{e}--Birkhoff--Witt
Theorem. Note that there is the following relation satisfied in
\(\mathcal{U}(\mathfrak{g})\):""".decode('utf-8')

    real_test_2=r"""Van~Oystaeyen and Zhang introduce a remarkable construction of an
\emph{associated Hopf algebra} to an $H$-extension $A/A^{co\,H}$, where $A$ as
well as $H$ are supposed to be commutative
(see~\cite[Sec.~3]{fo-yz:gal-cor-hopf-galois}, for noncommutative
generalisation see:~\cite{ps:hopf-bigalois,ps:gal-cor-hopf-bigal}). We will
denote this Hopf algebra by $L(H,A)$. 
% It satisfies the following two conditions:  \begin{enumerate} \item[(i)]
% $A/A^{co\,H}$ becomes a \emph{biGalois extension}, i.e. a left
% $L(H,A)$-comodule algebra and a right $H$-comodule algebra such that both
% coactions commute and $A/A^{co\,H}$ is both left $L(H,A)$-Galois and right
% $H$-Galois extension, \item[(ii)] if $H$ is \emph{cocommutative} then
% \(L(H,A)\simeq A^{co\,H}\otimes H\) (the proof in the commutative
% case~\cite[Cor.~3.4]{fo-yz:gal-cor-hopf-galois} works also in the
% noncommutative case).  \end{enumerate}
\citet[Prop.~3.2]{ps:gal-cor-hopf-bigal} generalises the van Oystaeyen and
Zhang correspondence (see also~\cite[Thm~6.4]{ps:hopf-bigalois}) to Galois
connection between generalised quotients of the associated Hopf algebra
\(L(H,A)\) (i.e. quotients by right ideal coideals) and subextensions of
a faithfully flat \(H\)-Hopf Galois extension of the base ring, dropping
commutativity of \(A\). In this work we construct a Galois correspondence
without the assumption that the coinvariants subalgebra is commutative and we
also \(  \) drop the Hopf--Galois assumption (Theorem~\ref{thm:existence}). Let us
also note that we work over a commutative base ring rather than a field.
Instead of Hopf theoretic approach of van Oystaeyen, Zhang and Schauenburg we
propose to look from the lattice theoretic perspective. Using an existence
theorem for Galois connections we show that if the comodule algebra \(A\) is
flat over \(R\) and the functor \(A\otimes_R-\) preserves infinite
intersections then there exists a Galois correspondence between subalgebras of
\(A\) and generalised quotients of the Hopf algebra \(H\). It turns out that
such modules are exactly the Mittag--Leffler modules
(Corollary~\ref{cor:mittag-leffler}). We consider modules with intersection
property in Section~\ref{sec:modules_with_int_property}, where we also give
examples of flat and faithfully flat modules which fail to have it.  Then we
discuss Galois closedness of generalised quotients and subalgebras. We show
that if a generalised quotient \(Q\) is such that \(A/A^{co\,Q}\) is
\(Q\)-Galois then it is necessarily closed under the assumption that the
canonical map of \(A/A^{co\,H}\) is onto
(Corollary~\ref{cor:Q-Galois_closed}). Later we prove that this is also
a necessary condition for Galois closedness if \(A=H\) or, more generally, if
\(A/A^{co\,H}\) is a crossed product, \(H\) is flat and \(A^{co\,H}\) is
a flat Mittag--Leffler \(R\)-module (Theorem~\ref{thm:cleft-case}). We also
consider the dual case: of \(H\)-module coalgebras, which later gives us
a simple proof of bijective correspondence between generalised quotients and
left ideal subalgebras of~\(H\) if it is finite dimensional
(Theorem~\ref{thm:newTakeuchi}). This Takeuchi correspondence, dropping the
assumptions of faithfully (co)flatness
of~\cite[Thm.~3.10]{ps:gal-cor-hopf-bigal}, was proved
by~\cite{ss:projectivity-over-comodule-algebras}, who showed that a finite
dimensional Hopf algebra is free over any its left coideal subalgebra. Our
proof avoids using this result. We also characterise closed elements of this
Galois correspondence in general case (Theorem~\ref{thm:closed-of-qquot}). As
we already mentioned, we show that a generalised quotient \(Q\) is closed if
and only if \(H/H^{co\,Q}\) is a \(Q\)-Galois extension. Furthermore, we show
that a left coideal subalgebra~\(K\) is closed if and only if \(H\sir H/K^+H\)
is a \(K\)-Galois coextension (see Definition~\ref{defi:coGalois}). This gives
an answer to the question when the bijective correspondence between
generalised quotients over which~\(H\) is faithfully coflat and coideal
subalgebra over which~\(H\) is faithfully flat holds without (co)flatness
assumptions. In the last section we extend the characterisation of closed
subalgebras and closed generalised quotients to crossed products.
( X
\section{Preliminaries}\label{subsec:basics}"""

    real_test_3=r"""Van~Oystaeyen and Zhang introduce a remarkable construction of an
\emph{associated Hopf algebra} to an $H$-extension $A/A^{co\,H}$, where $A$ as
well as $H$ are supposed to be commutative
(see~\cite[Sec.~3]{fo-yz:gal-cor-hopf-galois}, for noncommutative
generalisation see:~\cite{ps:hopf-bigalois,ps:gal-cor-hopf-bigal}). We will
denote this Hopf algebra by $L(H,A)$. 
% It satisfies the following two conditions:  \begin{enumerate} \item[(i)]
% $A/A^{co\,H}$ becomes a \emph{biGalois extension}, i.e. a left
% $L(H,A)$-comodule algebra and a right $H$-comodule algebra such that both
% coactions commute and $A/A^{co\,H}$ is both left $L(H,A)$-Galois and right
% $H$-Galois extension, \item[(ii)] if $H$ is \emph{cocommutative} then
% \(L(H,A)\simeq A^{co\,H}\otimes H\) (the proof in the commutative
% case~\cite[Cor.~3.4]{fo-yz:gal-cor-hopf-galois} works also in the
% noncommutative case).  \end{enumerate}
\citet[Prop.~3.2]{ps:gal-cor-hopf-bigal} generalises the van Oystaeyen and
Zhang correspondence (see also~\cite[Thm~6.4]{ps:hopf-bigalois}) to Galois
connection between generalised quotients of the associated Hopf algebra
\(L(H,A)\) (i.e. quotients by right ideal coideals) and subextensions of
a faithfully flat \(H\)-Hopf Galois extension of the base ring, dropping
commutativity of \(A\). In this work we construct a Galois correspondence
without the assumption that the coinvariants subalgebra is commutative and we
also \(  \) drop the Hopf--Galois assumption (Theorem~\ref{thm:existence}). Let us
also note that we work over a commutative base ring rather than a field.
Instead of Hopf theoretic approach of van Oystaeyen, Zhang and Schauenburg we
propose to look from the lattice theoretic perspective. Using an existence
theorem for Galois connections we show that if the comodule algebra \(A\) is
flat over \(R\) and the functor \(A\otimes_R-\) preserves infinite
intersections then there exists a Galois correspondence between subalgebras of
\(A\) and generalised quotients of the Hopf algebra \(H\). It turns out that
such modules are exactly the Mittag--Leffler modules
(Corollary~\ref{cor:mittag-leffler}. We consider modules with intersection
property in Section~\ref{sec:modules_with_int_property}, where we also give
examples of flat and faithfully flat modules which fail to have it.  Then we
discuss Galois closedness of generalised quotients and subalgebras. We show
that if a generalised quotient \(Q\) is such that \(A/A^{co\,Q}\) is
\(Q\)-Galois then it is necessarily closed under the assumption that the
canonical map of \(A/A^{co\,H}\) is onto
(Corollary~\ref{cor:Q-Galois_closed}). Later we prove that this is also
a necessary condition for Galois closedness if \(A=H\) or, more generally, if
\(A/A^{co\,H}\) is a crossed product, \(H\) is flat and \(A^{co\,H}\) is
a flat Mittag--Leffler \(R\)-module (Theorem~\ref{thm:cleft-case}). We also
consider the dual case: of \(H\)-module coalgebras, which later gives us
a simple proof of bijective correspondence between generalised quotients and
left ideal subalgebras of~\(H\) if it is finite dimensional
(Theorem~\ref{thm:newTakeuchi}). This Takeuchi correspondence, dropping the
assumptions of faithfully (co)flatness
of~\cite[Thm.~3.10]{ps:gal-cor-hopf-bigal}, was proved
by~\cite{ss:projectivity-over-comodule-algebras}, who showed that a finite
dimensional Hopf algebra is free over any its left coideal subalgebra. Our
proof avoids using this result. We also characterise closed elements of this
Galois correspondence in general case (Theorem~\ref{thm:closed-of-qquot}). As
we already mentioned, we show that a generalised quotient \(Q\) is closed if
and only if \(H/H^{co\,Q}\) is a \(Q\)-Galois extension. Furthermore, we show
that a left coideal subalgebra~\(K\) is closed if and only if \(H\sir H/K^+H\)
is a \(K\)-Galois coextension (see Definition~\ref{defi:coGalois}). This gives
an answer to the question when the bijective correspondence between
generalised quotients over which~\(H\) is faithfully coflat and coideal
subalgebra over which~\(H\) is faithfully flat holds without (co)flatness
assumptions. In the last section we extend the characterisation of closed
subalgebras and closed generalised quotients to crossed products.
( X
\section{Preliminaries}\label{subsec:basics}"""

    bracket_dict = {'[': ']', '(': ')', '{': '}', '\\(': '\\)', '\\[': '\\]', '\\{': '\\}', '\\lceil': '\\rceil', '\\begin': '\\end', '\\lfloor': '\\rfloor', '\\langle': '\\rangle'}
    # bracket_dict = {'[': ']', '(': ')', '{': '}', '\\lceil': '\\rceil', '\\begin': '\\end', '\\lfloor': '\\rfloor'}
    # bracket_dict = {'[': ']', '(': ')', '{': '}'}
    # bracket_dict = {'(': ')'}


    for lpos in [ (0,0), (20,10), (30, 10), (40, 10), (50, 10), (60, 3), (61, 44)]:
        bpos = byte_pos(real_test_2, *lpos)
        nlpos = line_pos(real_test_2, bpos)
        if lpos != nlpos:
            raise AssertionError('line_pos->byte_pos->line_pos: %s %d %s' % (lpos, bpos, nlpos))

    for bpos in [ 0, 100, 1000, 2000, 2500, 3400, 4000, 4280]:
        lpos = line_pos(real_test_2, bpos)
        nbpos = byte_pos(real_test_2, *lpos)
        if bpos != nbpos:
            raise AssertionError('byte_pos->line_pos->byte_pos: %d %s %d' % (bpos, lpos, nbpos))


    print("-"*10)
    print("test_1:")
    test = check_bracket(test_1, 2, 0, bracket_dict)
    print(test)
    if test != (-1, -1, ''):
        raise AssertionError('test 1: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_2:")
    test = check_bracket(test_2, 2, 0, bracket_dict)
    print(test)
    if test != (1, 0, '('):
        raise AssertionError('test 2: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_3:")
    test = check_bracket(test_3, 3, 0, bracket_dict)
    print(test)
    if test != (2, 0, '('):
        raise AssertionError('test 3: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_4:")
    test = check_bracket(test_4, 3, 0, bracket_dict)
    print(test)
    if test != (-1, -1, ''):
        raise AssertionError('test 4: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_5:")
    test = check_bracket(test_5, 3, 10, bracket_dict)
    print(test)
    if test != (2, 0, '('):
        raise AssertionError('test 5: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_6:")
    test = check_bracket(test_6, 2, 0, bracket_dict)
    print(test)
    # if test[:2] != (-1, -1):
        # raise AssertionError('test 6: FAILED')

    print("\n"+"-"*10)
    print("test_7:")
    test = check_bracket(test_7, 7, 0, bracket_dict)
    print(test)
    if test != (0, 0, '('):
        raise AssertionError('test 7: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_8:")
    test = check_bracket(test_8, 2, 0, bracket_dict)
    print(test)
    if test[:2] != (-1, -1):
        raise AssertionError('test 8: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_9:")
    test = check_bracket(test_9, 2, 0, bracket_dict)
    print(test)
    if test[:2] != (-1, -1):
        raise AssertionError('test 9: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_10:")
    test = check_bracket(test_10, 2, 0, bracket_dict)
    print(test)
    if test[:2] != (1, 9):
        raise AssertionError('test 10: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_11:")
    test = check_bracket(test_11, 2, 0, bracket_dict)
    print(test)
    if test[:2] != (0, 0):
        raise AssertionError('test 11: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_12:")
    test = check_bracket(test_12, 2, 0, bracket_dict)
    print(test)
    if test[:2] != (0, 0):
        raise AssertionError('test 12: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_13:")
    test = check_bracket(test_13, 2, 0, bracket_dict)
    print(test)
    if test[:2] != (-1, -1):
        raise AssertionError('test 13: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("test_14:")
    test = check_bracket(test_14, 2, 0, bracket_dict)
    print(test)
    if test[:2] != (-1, -1):
        raise AssertionError('test 14: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    print("real_test_1:")
    real_test_1_lines = real_test_1.splitlines()
    line = len(real_test_1_lines)-1
    col = len(real_test_1_lines[line])
    del real_test_1_lines
    print(check_bracket(real_test_1, line, col, bracket_dict))


    print("\n"+"-"*10)
    spos = byte_pos(real_test_2, 30, 10)
    print("real_test_2 at %d (30,10)" % spos)
    print("line 30: `%s`" % real_test_2.splitlines()[30])
    test = check_bracket(real_test_2, 30, 10, bracket_dict)
    print(test)
    if test[:2] != (-1, -1):
        raise AssertionError('real_test_2: FAILED: (%s,%s)' % test[:2])

    print("\n"+"-"*10)
    spos = byte_pos(real_test_3, 30, 10)
    print("real_test_3 at %d (30,10)" % spos)
    print("line 30: `%s`" % real_test_2.splitlines()[30])
    test = check_bracket(real_test_3, 30, 10, bracket_dict)
    print(test)
    if test[:2] != (30, 0):
        raise AssertionError('real_test_3: FAILED: (%s,%s)' % test[:2])

    if True:
        # speed test
        import time
        print("\n"+"-"*10)
        print("real_test_1 (time test):")

        debug = DEBUG
        DEBUG = False
        times = []
        for z in range(100):
            stime = time.time()
            check_bracket(real_test_1, line, col, bracket_dict)
            etime = time.time()
            times.append(etime-stime)
            del etime
            del stime
        print(sum(times)/len(times))
        DEBUG = debug

        """NOTE:
        The avrage is ~0.016, atplib#complete#CheckBracket(g:atp_bracketdict)
        over the same paragraphs complets in ~0.15.
        """


    debug = DEBUG
    DEBUG = False
    if True:
        print("\n"+"-"*10)
        print("real_test_2 (time test):")
        # speed test
        import time

        times = []
        for z in range(100):
            stime = time.time()
            check_bracket(real_test_2, 30, 10, bracket_dict)
            etime = time.time()
            times.append(etime-stime)
            del etime
            del stime
        print(sum(times)/len(times))
    DEBUG = debug

    debug = DEBUG
    DEBUG = False
    if True:
        print("\n"+"-"*10)
        print("real_test_3 (time test):")
        # speed test
        import time

        times = []
        for z in range(100):
            stime = time.time()
            check_bracket(real_test_3, 30, 10, bracket_dict)
            etime = time.time()
            times.append(etime-stime)
            del etime
            del stime
        print(sum(times)/len(times))
    DEBUG = debug
