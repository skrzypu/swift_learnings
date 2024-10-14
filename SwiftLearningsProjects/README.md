# AAPODAI - Another APOD AI App

## Why this application

I created AAPODAI to explore and learn various concepts:
- **Machine Learning in Swift**: The goal was to learn how to integrate machine learning models in a Swift project. The idea was to use machine learning to sort APOD (Astronomy Picture of the Day) items by the likelihood a user would open them.
- **Composable Architecture (TCA)**: I wanted to evaluate if TCA simplifies or complicates app development in Swift.
- **Experimenting with AI Assistance**: This app was implemented using ChatGPT as a learning tool. ChatGPT provided help with writing code for machine learning when I already understood the basics.
- **Machine Learning Model**: The ML model was trained on Kaggle and helps sort APOD items.
- **Backend Exploration**: The app integrates with both **Google Sheets** and **Airtable** as backends to store and retrieve which items were opened by the user. Users can select their preferred backend from the app's UI.
- **UI Design**: The UI was designed with the help of ChatGPT.

## Features

- **APOD Sorting**: Sorts APOD items based on the likelihood the user will open them, leveraging a trained machine learning model.
- **Backend Flexibility**: Users can choose between Google Sheets and Airtable for storing data on which items were opened.
- **Composable Architecture**: Built using the Composable Architecture pattern to manage state and business logic in a modular way.
- **Core ML Integration**: A Core ML model is used to predict the probability of a user opening an APOD item.
  
## How it works

1. **Fetch Items**: The app fetches APOD items from the NASA API.
2. **Generate Tags**: Tags are generated based on the explanation provided for each APOD item.
3. **Sort by Likelihood**: The app uses the trained machine learning model to sort the APOD items by the probability that the user will open them.
4. **Store Opened Items**: Opened items are stored in either Google Sheets or Airtable, depending on the user’s selection.

## Setup Instructions

### Machine Learning Model
The model used to predict the probability of a user opening an APOD item is not attached directly to the project. To set up the model:
1. Use the provided Python script to train the model on Kaggle.
2. Export the trained model as a `.mlmodel` file.
3. Add the model during the build process in Xcode.

### Backend Selection
In the app's UI, users can choose between Google Sheets and Airtable as the backend for storing which APOD items were opened.

## Technologies Used

- **Swift**: The app is built in Swift 6, targeting iOS.
- **Core ML**: For machine learning model integration.
- **Google Sheets & Airtable**: Used to store user interactions (which items were opened).
- **Composable Architecture (TCA)**: To handle the app's state management and business logic.

## How to Train the Model

To train the model:
1. Head over to Kaggle, where the provided Python code can be used to train the RandomForest model.
2. Export the model as a Core ML `.mlmodel` file.
3. Include the `.mlmodel` in your Xcode project during the build phase.

## License

This project is for educational purposes, and you are free to modify and adapt it as needed.
