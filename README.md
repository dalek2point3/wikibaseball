## Replication Files for "Does Copyright Affect Reuse? Evidence from Wikipedia and the Google Books Digitization Project"

This repository contains all data, programs and scripts needed to replicate the tables, figures and text of my paper on the role of copyright in affecting the diffusion of digitized Google Books material on Wikipedia.

In this repository you will find:

1. Rawdata collected from the various sources
2. Python scripts to get data from Wikipedia
3. Stata scripts to produce the main tables and charts
4. Latex source of the main PDF document

In order to replicate the analysis perform the following steps:

1. Clone the repository to your local computer using the following command. This will create a copy of the repository in your local drive. 
    git clone https://github.com/dalek2point3/wikibaseball.git
2. Open `scripts/stata/main.do` and change the path to the `wikibaseball` folder.
3. Run the stata scripts with `stata -b main.do`
4. Compile the LaTex source with `pdflatex paper.tex`, `bibtex paper` and `pdflatex paper.tex`.

You should have the complete paper with all the figures, tables and appendices recreated.