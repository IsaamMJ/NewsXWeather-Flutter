
# Weather and News Aggregator App with Weather-Based News Filtering

## App Overview
The app I’ve developed is a **Weather and News Aggregator App with Weather-Based News Filtering**. The app combines weather updates with news articles, filtered based on the current weather conditions.

---

## Step 1: Research and Exploration
I began by researching similar apps in the market. However, I couldn't find any app that perfectly matched my concept. So, I expanded my research to explore existing **news** and **weather apps** to gather UI/UX inspiration.

---

## Step 2: Branding
For the branding, I needed to choose a **brand name**, **logo**, and **color palette**. After a detailed search, I decided on the name **SKYFEED**. Most news apps typically use a strong **red** color and weather apps use **blue**, but I chose not to combine both colors. Instead, I selected my own color palette to ensure a unique and aesthetic appeal.

Please visit the **Figma file** to view the finalized logo, color palette, low-fidelity wireframes, and user flows:

[Figma Link](https://www.figma.com/design/d64nrVQmWXn50e6gHrRVQl/Untitled?node-id=0-1&t=gcHqDSygxzmkFTfu-1)

---

## Figma Design Overview
This Figma file contains the detailed design process for the app, including:
- The finalized **logo**
- The **color palette**
- **User flow**
- **Low-fidelity wireframes**

The file showcases how we’ve translated the brand vision into a visual identity and provides a clear structure of how users will interact with the app. The wireframes also demonstrate the basic layout of key screens, serving as a foundation for further UI development.

---

## Step 3: Folder Structure
For the development phase, I decided on a **feature-based folder structure** with a clean architecture approach to ensure modularity and maintainability throughout the app.

---

## Step 4: Technologies and Tools
For the app development, I will be using the following tools and libraries:
- **GetX** for state management.
- **Shared Preferences** for storing local data.
- **Firebase** for user authentication.

---

## Setup Instructions

To run the project locally, follow these setup instructions:

1. **Clone the repository**
   ```bash
   git clone <repository_url>

2. **Install dependencies**
   Navigate to the project directory and install the necessary dependencies:

   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   The app requires the following environment variables for the news and weather APIs.
   Create a `.env` file in the root of your project and add the following dummy API keys:

   ```plaintext
   # News API Key
   NEWS_API_KEY=dummy_news_api_key
   # Weather API Key
   WEATHER_API_KEY=dummy_weather_api_key
   # Base URL for News API
   BASE_URL=https://newsapi.org/v2
   ```

4. **Run the app**
   Once you've added your API keys and set up the environment variables, you can run the app using:

   ```bash
   flutter run
   ```

## For Demo

You can view the **demo video** showcasing the app's UI and features here:

[Watch the Demo Video](https://drive.google.com/drive/folders/1f_OQuLS5uD0RJVf22GtecsUJ5iWsiFxQ?usp=drive_link)

---

## Future Implementations

* **Storing user preferences in the database** for better customization and personalized experiences.
* **Improving responsiveness** for different screen sizes to ensure a seamless experience across devices.
* **Enhancing error handling** to provide better user feedback and ensure stability.
* **Adding build profiles** for different environments (e.g., production, staging, development) to streamline the deployment process.

---


