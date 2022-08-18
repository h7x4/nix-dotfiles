;;; Compiled snippets and support files for `latex-mode'
;;; Snippet definitions:
;;;
(yas-define-snippets 'latex-mode
										 '(("tt" "\\begin{truthtable}\n  {$0}\n	{}\n\n\\end{truthtable}" "truthtable" nil nil nil "/home/h7x4/.emacs.d/snippets/latex-mode/truthtable" nil nil)
											 ("sxs" "\\begin{subexcs}\n  \\subexc{}\n	  $0\n\\end{subexcs}" "subexcs" nil nil nil "/home/h7x4/.emacs.d/snippets/latex-mode/subexcs" nil nil)
											 ("pic" "\\pic{./graphics/$0}\n" "\\pic{}" nil nil nil "/home/h7x4/.emacs.d/snippets/latex-mode/pic" nil nil)
											 ("ntnu-doc" "\\documentclass[12pt]{article}\n\\usepackage{ntnu}\n\n\\author{Øystein Tveit}\n\\title{$0}\n\n\\begin{document}\n  \\ntnuTitle{}\n  \\break{}\n  \n  \\begin{excs}\n    \\exc{}\n      $1\n  \\end{excs}\n\n\\end{document}" "ntnu-doc" nil nil nil "/home/h7x4/.emacs.d/snippets/latex-mode/ntnu-doc" nil nil)
											 ("xs" "\\begin{excs}\n  \\exc{}\n	  $0\n\\end{excs}" "excs" nil nil nil "/home/h7x4/.emacs.d/snippets/latex-mode/excs.yasnippet" nil nil)))


;;; Do not edit! File generated at Wed Jan 27 13:29:39 2021
