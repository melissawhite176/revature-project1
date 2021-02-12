# Revature - Project 1

## Wikipedia Big Data Analysis
Project 1's analysis consists of using big data tools to answer questions about datasets from Wikipedia. There are a series of basic analysis questions, answered using Hive or MapReduce. The tool(s) used are determined based on the context for each question. The output of the analysis includes MapReduce jarfiles and/or .hql files so that the analysis is a repeatable process that works on a larger dataset, not just an ad hoc calculation. Assumptions and simplfications are required in order to answer these questions, and the final presentation of results includes a discussion of those assumptions/simplifications and the reasoning behind them. In addition to answers and explanations, this project requires a discussion of any intermediate datasets and the reproduceable process used to construct those datasets. Finally, in addition to code outputs, this project requires a simple slide deck providing an overview of results. 
The questions follow: 
1. Which English Wikipedia article got the most traffic on January 20, 2021? 
2. What English Wikipedia article has the largest fraction of its readers follow an internal link to another wikipedia article? 
3. What series of Wikipedia articles, starting with Hotel California, keeps the largest fraction of its readers clicking on internal links? 
4. Find an example of an English wikipedia article that is relatively more popular in the Americas than elsewhere? 
5. How many users will see the average vandalized Wikipedia page before the offending edit is reversed? 
6. Run an analysis you find interesting on the Wikipedia datasets we're using.

### Presentations
- Bring a simple slide deck providing an overview of your results.  You should present your results, a high level overview of the process used to achieve those results, and any assumptions and simplifications you made on the way to those results.
- I may ask you to run an analysis on the day of the presentation, so be prepared to do so.
- We'll have 5-10 minutes a piece, so make sure your presentation can be covered in that time, focusing on the parts of your analysis you find most interesting.
- Include a link to your github repository at the end of your slides

### Technologies
- Hadoop MapReduce
- YARN
- HDFS
- Scala 2.13
- Hive
- Git + GitHub

### Links for data
- [All Analytics](https://dumps.wikimedia.org/other/analytics/)
- [Pageviews Filtered to Human Traffic](https://dumps.wikimedia.org/other/pageviews/readme.html)
  - https://wikitech.wikimedia.org/wiki/Analytics/Data_Lake/Traffic/Pageviews
- [Page Revision and User History](https://dumps.wikimedia.org/other/mediawiki_history/readme.html)
  - https://wikitech.wikimedia.org/wiki/Analytics/Data_Lake/Edits/Mediawiki_history_dumps#Technical_Documentation
- [Monthly Clickstream](https://dumps.wikimedia.org/other/clickstream/readme.html)
  - https://meta.wikimedia.org/wiki/Research:Wikipedia_clickstream
