# ob-html-chrome

`ob-html-chrome` provides an alternative language for HTML in Org
`#+BEGIN_SRC` blocks.

When the block is evaluated (e.g., with <kbd>C-c C-c</kbd>, or when
using Org Export) the contents of the block are converted to a PNG
file by loading the content in to a "headless" instance of Chrome and
taking a screenshot of the resulting page.

The results are then inserted in to the buffer and included during
export.

This is similar functionality to the
[ob-browser](https://github.com/krisajenkins/ob-browser) package, but
without having to install additional Javascript packages.

## Installation

[![MELPA](https://melpa.org/packages/ob-html-chrome-badge.svg)](https://melpa.org/#/ob-html-chrome)

`ob-html-chrome` is available on [MELPA](https://melpa.org/). If you are
not already using MELPA, add this to your `.emacs` (or equivalent):

```lisp
(require 'package)
(add-to-list 'package-archives
	         '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
```

and then evaluate that code.

You can then install `ob-html-chrome` with the following command:

<kbd>M-x package-install [RET] ob-html-chrome [RET]</kbd>

or by adding the following to your `.emacs`:

```lisp
(unless (package-installed-p 'ob-html-chrome)
  (package-install 'ob-html-chrome))
```

or by using [`use-package`](https://github.com/jwiegley/use-package):

``` lisp
(use-package ob-html-chrome
  :ensure t)
```

After installing, enable with:

``` lisp
(require 'ob-html-chrome)
```

To guard against security risks, Org defaults to prompting for
confirmation every time you evaluate a code block (see [Code
evaluation and security
issues](http://orgmode.org/manual/Code-evaluation-security.html) for
details). To disable this for `ob-html-chrome` blocks you can add the
following code to your `.emacs` file and evaluate it.

``` lisp
(setq org-confirm-babel-evaluate
      (lambda (lang body)
        (not (string= lang "html-chrome"))))
```

## Customisation

Before usage you will need to customize the variable
`org-babel-html-chrome-chrome-executable` to be the full path
(including filename) to the executable Chrome binary to run.

For example, on Windows, something like:

``` emacs-lisp
(setq org-babel-html-chrome-chrome-executable
  "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe")
```

You may also use the `customize` framework to set and save this value.

## Usage

Enter an Org SRC block and specify `html-chrome` as the language. For
example:

``` org
#+BEGIN_SRC html-chrome :file test
<p>This is a simple paragraph.</p>
#+END_SRC
```

Then place the point within the block and press <kbd>C-c C-c</kbd> to
evaluate it.

The HTML will be processed by Chrome and the image saved to the
location given in the `:file` parameter, the `.png` extension is added
automatically.

A `#+RESULTS` block will be added to the file with a reference to the
generated PNG image.

Temporary files generated during this process are written to the same
directory as the `.org` file, so any relative file references in the
HTML content should be relative to that directory.

## Header arguments

### `:file ...`

Specifies the filename the output should be written to if. This should
be the basename of the file, the `.png` extension is not necessary.

This is optional. If it is omitted then the filename is generated
automatically with the following algorithm.

If the block is named using `#+NAME:` then the name is used, with
`.png` appended.

If the block is not named then the text of the closest enclosing
heading is converted to dashed-words (lower case, `-` between words,
alphanumerics only), `.png` is appended, and that is used as the name.

This can cause clashes if you have multiple headings with the same
text and do not use `:file` or `#+NAME:`, so do not do that.

#### `:file` examples

``` org
* First HTML example

#+NAME: example1
#+BEGIN_SRC: html-chrome :file test
<p>The file is called test.png, because of the :file header
  argument.</p>
#+END_SRC
```

``` org
* Second HTML example

#+NAME: example1
#+BEGIN_SRC: html-chrome
<p>The file is called example1.png, because the :file header
  argument is missing but the block is named example1.</p>
#+END_SRC
```

``` org
* Third HTML example

#+BEGIN_SRC: html-chrome
<p>The file is called third-html-example.png, because the :file
   header argument is missing and the block does not have a name.
   The text of the closest enclosing heading has been used.</p>
#+END_SRC
```

### `:flags ...`

Use `:flags` to pass additional arguments on the Chrome command line.
The contents of this argument will be included, verbatim, on the
command line, you must ensure it is quoted correctly.

#### `:flags` examples

My system has a high DPI display that results in the screenshots
having a very small font. The `--force-device-scale-factor=n` flag
lets you specify a scaling factor for Chrome.

In addition, I'd like the results to be a 640x480px PNG file, using
the `--window_size` flag.

``` org
#+NAME: flag-example
#+BEGIN_SRC html-chrome :flags --window-size=320,240 --force-device-scale-factor=2
  <p>This is an HTML paragraph.</p>
#+END_SRC
```

You can use the `#+PROPERTY:` syntax to make this a global property on
the file, with:

``` org
#+PROPERTY: header-args:html-chrome :flags --window-size=320,240 --force-device-scale-factor=2
```

Or set a per-heading (possibly inherited) property drawer value

``` org
* Passing header args as properties
  :PROPERTIES:
  :header-args:html-chrome: :flags --window-size=320x240 --force-device-scale-factor=2
  :END:

#+NAME: flag-example
#+BEGIN_SRC html-chrome
  <p>This is an HTML paragraph.</p>
#+END_SRC
```

### `:exports`

The `:exports` argument has its normal meaning per [Exporting code
blocks](https://orgmode.org/manual/Exporting-code-blocks.html) in the
Org manual.

The default value is `both`, indicating that the HTML and the PNG
image should be included in the exported output.

Set this to `results` to include just the image in the exported
output.

``` org
#+NAME: exports-results-example
#+BEGIN_SRC html-chrome :exports results
  <p>Only the image appears in exported output.</p>
#+END_SRC
```

## Displaying images inline

If your Emacs is configured to show images you can enable this in Org
with `org-display-inline-images`.

To automatically refresh any displayed images after evaluating a block
include the following hook in your `.emacs` file.

``` emacs-lisp
(add-hook 'org-babel-after-execute-hook
	  'org-redisplay-inline-images)
```

## License

GPLv3, see the `LICENSE` file in the repository and the copyright
statement in the code for further information.
