# helm-c-yasnippet [![melpa badge][melpa-badge]][melpa-link] [![melpa stable badge][melpa-stable-badge]][melpa-stable-link] [![Github Actions Status][github-actions-badge]][github-actions-link]

helm source for yasnippet.el

## Screenshot

![helm-c-yasnippet](image/helm-c-yasnippet.png)


## Installation

`helm-c-yasnippet` is available on [MELPA][melpa-link] and [MELPA-STABLE][melpa-stable-link].

You can install `helm-c-yasnippet` with the following command.

<kbd>M-x package-install [RET] helm-c-yasnippet [RET]</kbd>


## Sample Configuration

```lisp
(require 'yasnippet)
(require 'helm-c-yasnippet)
(setq helm-yas-space-match-any-greedy t)
(global-set-key (kbd "C-c y") 'helm-yas-complete)
(yas-global-mode 1)
(yas-load-directory "<path>/<to>/snippets/")
```

## Browsing without a word prefix

By default, `helm-yas-complete` filters snippet names by the word before point
and replaces that word when inserting a snippet. This filter is separate from
the visible Helm search input: invoking the command after ordinary text can
show no candidates even when the search input is empty.

To browse snippets without this word-prefix filter and insert at point without
replacing preceding text:

```lisp
(setq helm-yas-use-prefix nil)
```

The default value is `t`, preserving existing completion behavior. This option
does not change snippet conditions or active-region handling.

[melpa-link]: https://melpa.org/#/helm-c-yasnippet
[melpa-stable-link]: https://stable.melpa.org/#/helm-c-yasnippet
[melpa-badge]: https://melpa.org/packages/helm-c-yasnippet-badge.svg
[melpa-stable-badge]: https://stable.melpa.org/packages/helm-c-yasnippet-badge.svg
[github-actions-link]: https://github.com/emacs-jp/helm-c-yasnippet/actions
[github-actions-badge]: https://github.com/emacs-jp/helm-c-yasnippet/workflows/CI/badge.svg
