---
layout: post
title: Hiding local file changes from git
date: 2017-08-30 15:00:00 +0200
tags: [git, quickie]
---
I'm currently working on refactoring some Angular components and update styling for our booking confirmation screen. My colleague Matt showed me a handy way to manually stick a big object in the relevant model file so that I can directly go to the booking confirmation screen without having to click through the whole search/price/book process. However, now every time I do `git status`, I get this:

```shell
$ gst
On branch FE-1169_book_confirm_info
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   src/app/price/confirmation/confirmation-model.js

no changes added to commit (use "git add" and/or "git commit -a")
```

This is annoying. That "modified" file is not actually modified in the sense of version control - I don't plan to commit my changes later and push them to the upstream repo. I don't want to see it when I do `git status`, and I especially don't want to add the changes when I do `git add`.

So I've found a neat way to work around this.

1. `git update-index --skip-worktree src/app/price/confirmation/confirmation-model.js` will "hide" the file from git; it will no longer show up as a file that I've changed. If the file gets changed remotely and I do `git pull`, git will give me a conflict message and explain what needs to be done to resolve it. And `git reset --hard` will not reset the file, allowing the changes to persist for a long time (e.g. across branches).
2. To view a list of all files I've hidden in this way, I can just do `git ls-files -v . | grep ^S`. All the files listed with status code `S` (for `skip-worktree`) will be displayed.
3. To "unhide" a file, I can simply do `git update-index --no-skip-worktree src/app/price/confirmation/confirmation-model.js`.

## How is this different to .gitignore?

The most common way to "hide" files is to add them to `.gitignore`. This won't work for me: the file I'm editing is already tracked in git, which means changes will still show up in `git status`.

`.gitignore` is intended for things like build artifacts, which shouldn't be committed to the repo _at all_.

## How is this different to assume-unchanged?

Now we're getting somewhere! `git update-index --assume-unchanged` is fairly similar in function to `--skip-worktree`. The difference is that `--assume-unchanged` seems to be designed for performance uses rather than for local overwriting of configs and the like. It's meant to be used for cases where checking for file changes is very expensive. Critically, operations like `git pull` are very likely to reset this flag and discard all your changes with no option to recover them.

## Tips

If you plan on using these, I recommend you add some aliases to your `.zshrc`/`.bashrc` file:

```shell
alias ghide='git update-index --skip-worktree'
alias gunhide='git update-index --no-skip-worktree'
alias ghidden='git ls-files -v . | grep ^S'
```

Then you can do `ghide path/to/file` to hide, `gunhide path/to/file` to unhide, and `ghidden` to list all hidden files.

I hope you find this useful! Do remember, if you are going to use this, just do `ghidden` every so often to check whether you haven't forgotten about a hidden file. (I'm still looking for a clever way to show this in `git status`...)
