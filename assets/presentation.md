---
title: Optimising Project Navigation - Josiah Talks
author: Josiah Tan
date: 2021-12-19
extensions:
  - render
  - terminal
  - qrcode
---

# Project Navigation

---

# Project Navigation

## File Navigation

---

# Project Navigation

## File Navigation

## File trees

--- 

# Project Navigation

## File Navigation

## File trees

- That file browser thing 

--- 


# Optimisation 1

## fuzzy finding

---

# Optimisation 1

## fuzzy finding

- basically googling for files

---


# Optimisation 2

## marks

---

# Optimisation 2

## marks
  - basically a keyboard shortcut mapped to a file

---

# Evidently...

---

# Evidently...

- We have mastered file finding already

---

# Evidently...

- We have mastered file finding already

- so what's next?

---

# The Problem

## Switching Projects

- ~/Desktop/josiah/uni/elec2104/
- ~/Desktop/josiah/uni/amme2301_solids/

```terminal8
bash -c "cd ~/Desktop/josiah/uni/elec2104/; $SHELL"
```

---

# The actual problem

- How about navigating to this project?

- ~/Desktop/josiah/work/resumes/

```terminal8
bash -c "cd ~/Desktop/josiah/uni/amme2301_solids/; $SHELL"
```

---


# So...

---

# So...

## I was lost

---

# So...

## I was lost

- So I complained to Steven
- (president of the robotics club, the legend himself)

---

# Symlinks

---

# Symlinks
- Folder/file shortcuts

---

# Symlinks
- Folder/file shortcuts

## Projects
- ~/Desktop/josiah/uni/elec2104/
- ~/Desktop/josiah/uni/amme2301_solids/
- ~/Desktop/josiah/work/resumes/

---

# Symlinks
- Folder/file shortcuts

## Projects
- ~/Desktop/josiah/uni/elec2104/
- ~/Desktop/josiah/uni/amme2301_solids/
- ~/Desktop/josiah/work/resumes/

## Linking
- ln -s ~/Desktop/josiah/uni/elec2104 elec2104
- ln -s ~/Desktop/josiah/uni/amme2301_solids amme2301_solids 
- ln -s ~/Desktop/josiah/work/resumes/ resumes

```terminal8
bash -c "cd ~/symlinks; $SHELL"
```
---

# Tmux 

---

# Tmux 
- Chrome tabs and windows 

---

# Tmux 
- Chrome tabs and windows 
  - but for terminals

---

## What I want:
- Different projects in different terminals

---

# So What Tools Do We Have?

---

# So What Tools Do We Have?
## fuzzy finding

- googling for files

## marks
- Keyboard shortcuts for files

## symlinks
- folder/file shortcuts

## tmux
- terminal management

---

## Combine everything together

---

## Combine everything together

### To Create The Ultimate Plugin

---

## Combine everything together

### To Create The Ultimate Plugin

- quick-projects-nvim

---

## Let me show you!

---

## Any Questions?
```qrcode
https://github.com/Josiah-tan/quick-projects-nvim
```
