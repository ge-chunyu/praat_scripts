# My Praat Scripts

This repository stores the Praat scripts I wrote myself. There are a vast amount of praat scripts available, so why write by oneself? The main reason is that I find most of the scripts are too specific and can only serve specific uses. This is not modular and generalizable. As for phonetic studies, a general workflow can be established. I want to capture the essential parts of this workflow and write the basic scripts.

The inspiration and motivation for this repository is the [*Unix philosphy*](https://en.wikipedia.org/wiki/Unix_philosophy). The Unix philosophy requires one tool to do one thing and do it well. 

The workflow is based on my own research and it is sure to be inadequate. There are also a lot of people using tools other than Praat. But I think the idea is general. For phonetic studies to be reproducible, the work has to be modular or orthogonal.

## The general workflow of phonetic studies

## The structure of a script

Most of the Praat scripts are written to do **batch** jobs. Therefore, a general structure of script can be abstracted.

To do a batch job, a script can be decomposed into the following parts:

- an I-O interface to the user: a `form` in Praat terms;
- a series of files/directories to be processed: a `String` in Praat terms;
- some thing to do to the files/directories: a `Procedure` in Praat terms.

People usually write a for loop and put all the things to do within it. This approach is not modular and reproducible. Thankfully, Praat offers a function called `Procedure`. I think to decompose the things to do into clearly-defined steps and wrap them using `Procedure` can be useful. The functionality of a `Procedure` can be easily used by other scripts, and it increases the *reusability* of code.

I included a `script_strcture.praat` script in this repo. It serves as a template for scripting. Simply add `Procedures` at the end of the script and put them into the for loop. This saves a lot of typing.

## The coherence of environment