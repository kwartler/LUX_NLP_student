# LUX_NLP_student
University of Luxembourg  NLP Course Repo

**Each day, please perform a `git pull` to get the most up to date files and lessons.**

## Lesson Structure
Each day's lesson is contained in the **lesson** folder.  Each individual lesson folder will contain the following files and folders.
 
* slides - A copy of the presentation covered in the class.  Provided because some students print the slides and take notes.
* `data` sub folder - contains the data we will work through together
* `scripts` - commented scripts to demonstrate the lesson's concepts
* `HW` - the daily homework will be in this folder.

## Environment Setup

* You *must* install R, R-Studio & Git locally on your laptop or if you have issues, you can work from a server instance with all software.  Please ask Prof K or you can use  (www.rstudio.cloud)[www.rstudio.cloud] which is another option but the free tier has significant time limitations. Part of day 1 will be devoted to ensuring people's instances work correctly.

- If you encounter any errors during set up don't worry!  Please request technical help from Prof K.  The `qdap` library is usually the trickiest because it requires Java and `rJava`.  So if you get any errors, try removing that from the code below and rerunning.  This will take **a long time**, so if possible please run prior to class two, and at a time you don't need your computer ie *at night*.  We will work to resolve any issues prior to class or during Monday's live session.

## R Packages

```
# Easiest Method to run in your console
install.packages('pacman')
pacman::p_load(ggplot2, ggthemes, stringi, hunspell, qdap, spelling, tm, dendextend,
wordcloud, RColorBrewer, wordcloud2, pbapply, plotrix, ggalt, tidytext, textdata, dplyr, radarchart, 
lda, LDAvis, treemap, clue, cluster, fst, skmeans, kmed, text2vec, caret, glmnet, pROC, textcat, 
xml2, stringr, rvest, twitteR, jsonlite, docxtractr, readxl, udpipe, reshape2, openNLP, vtreat, e1071,
lexicon, echarts4r, lsa, yardstick, textreadr, pdftools, tesseract, mgsub, mapproj, ggwordcloud)

# Additionally we will need this package from a different repo
install.packages('openNLPmodels.en', repo= 'http://datacube.wu.ac.at/')

# You can install packages individually such as below if pacman fails.
install.packages('tm')

# Or using base functions use a nested `c()`
install.packages(c("lda", "LDAvis", "treemap"))

```

## Installing rJava (needed for Qdap) on MAC!
For most students these two links have helped them install java, and then make sure R/Rstudio can find it when loading `qdap`.  **Keep in mind, you don't have to install qdap, to earn a good grade** This is more for use of some functions and the `polarity()` function primarily.

* [link1](https://zhiyzuo.github.io/installation-rJava/)
* [link2](https://stackoverflow.com/questions/63830621/installing-rjava-on-macos-catalina-10-15-6)

Once java is installed this command *from terminal* often resolves the issue:
```
sudo R CMD javareconf
```

If this causes hardship, don't worry!  You can use a server instance instead.


## Homework & Case Due dates

|HW |Covered in Class.          |Due    |
|-----|---------------------------|-------|
|HW1  |Basics of R Coding: Oct 11 |Oct 12 |
|HW2  |Load & Clean Docs: Oct 12  |Oct 14 |
|HW3  |Sentiment  & Unsupervised:Oct 14/15  |Oct 20 |
|HW4  |Document Classification    |Oct 23 |
|Case |NA                         |Nov 5  |
|Paper|NA                         |Nov 5  |

## Prerequisite Work
*  Read chapter 1 of the book [Text Mining in Practice with R](https://www.amazon.com/Text-Mining-Practice-Ted-Kwartler/dp/1119282012) book.

## Recorded Lectures (will be deleted Dec 1)
* [Oct 11](https://harvard.zoom.us/rec/share/KF0ygFcaaijV5_IYHB45y29-ILbcHFZJa7ZiWt8cPYXTA_xv8E9aUPmXyU6rVylQ.RLeK0Qo-d-X0UrCm)
* [Oct 12](https://harvard.zoom.us/rec/share/fyisI__Y6S25EdG07br9KR-S2lS_-XYDdQlaYoChgdhlCX_co8h_S5S9KZfTRmOr.8k64uWjfg6SaDDKX)
* [Oct 13](https://harvard.zoom.us/rec/share/qvb2dJA6ggOJkqeW5atdEceY5YU51pCXGGYHPjdmlbpe_GZDMKU6dMvd6sWVDaJT.Sm6hnyd2vx3PQuVC)
* [Oct 14](https://harvard.zoom.us/rec/share/VUpmEOlKQMHRczx7iHSgAf1XI9YYKFx3cbXoGoIXeIOUJQhVDqI2aE1f7kM3kaUi.f06uZRU0CKlMqg3v)
* [Oct 15](https://harvard.zoom.us/rec/share/7tu-8Gr9ZyT0R_6HJ2bAgCq8uuXNcbt0a2TssKEa21wPr_dKqTyrQLcHLg6tv1ke.2g-wfrkJZRbTsSkT)
* [Oct 18](https://harvard.zoom.us/rec/share/Y9lyYXtHwmwe7z0hyrR51IlrPWGagtUUPxKFxWMX-qVBBgg6DwH4YnVzAOQKHBbk.DWryUUOXkSaSrPyT)
* [Oct 19](https://harvard.zoom.us/rec/share/4eVw7WHra710i80LIKH_HBzx00_ytdaSa_pvYJ2InDQTjNDyi0LUIvlLNxAk46qx.EJC_dHAyeGfb6DwZ)
* [Oct 20](https://harvard.zoom.us/rec/share/f2E4FkMnjyyAkpke_1S_UgMSM2_kSHOSUWOlDS17ukST46E3fOgcn8VZpkotO24V.mM8iua1Gk-bMO6Ed)


## Case Examples for inspiration
[Wall Street Bets](https://www.wsbets.dev/GME.html)
