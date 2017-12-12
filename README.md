# Predicting the Hugo Awards
Build classifier so that, given nominee of the Hugo Award, we will try to predict whether it will win in that year.

The Hugo Awards are the biggest prize in science fiction literature. What factors determine which of the nominees will be the winner? 

Are there any special in-circle insights we might hypothesize? Here we will try to find out.

This project was a fun way to learn the basics of RmarkDown, the ins and outs of R - fetching data, cleaning, playing with the data, using the RandomForest and visualizations to help with feature engineering - and basic statistical learning methods. 

In the future I hope to have more attractive visuals and more rigorous tutorials about RandomForests. Thus far, my theoretical foundation for Random Forests comes from [this paper](https://arxiv.org/pdf/1407.7502.pdf).

Below is a brief directory. If you want to see my results directly, you can see [here](https://github.com/tommymtang/Predicting-the-Hugo-Awards/blob/master/Predict/Prediction_and_Analysis.md). 

Enjoy!

# Dataset
The data used for this project was scraped from Wikipedia, an old Locus Awards archive, and Goodreads.com. The data is collected in [this folder](https://github.com/tommymtang/Predicting-the-Hugo-Awards/tree/master/Dataset).

For a structured rundown of how I scraped and cleaned the data, see [this document](https://github.com/tommymtang/Predicting-the-Hugo-Awards/blob/master/Extract%20and%20Clean/Extract_and_Clean.md). 

For details on the scripts I used for data cleaning, see this [script] (https://github.com/tommymtang/Predicting-the-Hugo-Awards/blob/master/Scripts/prep-Data.R).

I collected tables of nominees of winners for: 
* the Locus Awards
* the Campbell Awards
* the Nebula Awards 
* the Hugo Awards

And next, for each title in the Hugo Awards table, I found its Goodreads average rating count and searched through the other awards tables to mark down whether it was nominated for the other awards, and if so, whether it had won.

# Prediction and Analysis
As mentioned previously, this [file](https://github.com/tommymtang/Predicting-the-Hugo-Awards/blob/master/Predict/Prediction_and_Analysis.md) is a good tutorial for how I made and chose the RandomForest classifier. 

For details on the scripts I used, see [here](https://github.com/tommymtang/Predicting-the-Hugo-Awards/blob/master/Scripts/analysis.R).