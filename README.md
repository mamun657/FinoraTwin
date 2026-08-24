# 💰 FinoraTwin

## AI-Powered Financial Decision Platform for Small Businesses

<p align="center">
  <img src="https://img.shields.io/badge/FLUTTER-MOBILE-blue?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/DART-APPLICATION-0175C2?style=for-the-badge&logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/.NET-BACKEND-512BD4?style=for-the-badge&logo=.net" alt=".NET"/>
  <img src="https://img.shields.io/badge/PYTHON-AI%20SERVICES-3776AB?style=for-the-badge&logo=python" alt="Python"/>
  <img src="https://img.shields.io/badge/POSTGRESQL-DATABASE-4169E1?style=for-the-badge&logo=postgresql" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/REST-API-success?style=for-the-badge" alt="REST API"/>
  <img src="https://img.shields.io/badge/AI-FINANCIAL%20COPILOT-purple?style=for-the-badge" alt="AI Financial Copilot"/>
</p>

---

## 📌 Project Overview

FinoraTwin is an AI-powered financial decision platform designed to help small businesses understand their financial condition, identify financial risks, simulate business decisions, and receive actionable recommendations from their financial data.

The platform combines a Flutter-based mobile application with an ASP.NET Core backend, PostgreSQL database, and AI-powered financial analysis capabilities.

Instead of only displaying historical financial records, FinoraTwin transforms business financial data into understandable insights, financial health indicators, risk signals, simulations, and decision-oriented recommendations.

---

# 🎯 Problem Statement

Small businesses often have access to financial data but lack the tools required to properly understand and use that data for decision-making.

Business owners may know their sales, expenses, loans, cash position, and financial records, but determining what those numbers actually mean can be difficult.

Common problems include:

* Difficulty understanding overall financial health
* Limited visibility into cash pressure and liquidity risks
* Difficulty identifying financial leaks and unusual spending patterns
* Uncertainty about whether a business can safely take additional funding
* Difficulty evaluating the financial impact of future decisions
* Lack of personalized financial recommendations
* Financial information being stored without being transformed into useful decisions
* Dependence on manual calculations and subjective judgment
* Difficulty connecting historical financial data with future business scenarios

Traditional financial management tools often focus mainly on recording and displaying data.

FinoraTwin focuses on going one step further:

```text
Financial Data
      ↓
Financial Analysis
      ↓
Risk Detection
      ↓
Scenario Simulation
      ↓
AI-Powered Insight
      ↓
Actionable Decision
```

---

# 💡 Purpose

The purpose of FinoraTwin is to build an intelligent financial decision-support platform for small businesses.

The system is designed to help business owners:

* Understand their current financial condition
* Monitor important financial indicators
* Detect potential financial problems
* Identify cash pressure
* Detect financial leaks
* Evaluate capital and funding decisions
* Simulate possible business scenarios
* Set and track financial goals
* Receive AI-assisted financial explanations and recommendations
* Make better financial decisions using structured business data

The core purpose is not simply to store financial information.

The goal is to transform financial information into meaningful decisions.

---

# 🚀 Proposed Solution

FinoraTwin provides a centralized financial intelligence platform that connects business data, financial analysis, simulation, and AI assistance.

The proposed solution consists of several connected layers:

```text
┌─────────────────────────────────────┐
│          Flutter Application        │
│                                     │
│ Dashboard                           │
│ Financial Health                    │
│ Transactions                        │
│ Goals                               │
│ Cash Pressure                       │
│ Leak Detector                       │
│ Capital Simulator                   │
│ Scenarios                           │
│ AI Copilot                          │
└──────────────────┬──────────────────┘
                   │
                   │ REST API
                   ▼
┌─────────────────────────────────────┐
│            ASP.NET Core API         │
│                                     │
│ Authentication                      │
│ Business Management                 │
│ Financial Processing                │
│ Transactions                        │
│ Capital Analysis                    │
│ AI Integration                      │
│ Authorization                       │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│             PostgreSQL              │
│                                     │
│ Users                               │
│ Businesses                          │
│ Transactions                        │
│ Financial Snapshots                 │
│ Loans                               │
│ Loan Payments                       │
│ Simulations                         │
│ Recommendations                    │
│ Documents                           │
│ Audit Logs                          │
└─────────────────────────────────────┘
```

---

# ✨ Main Features

## 🔐 Authentication

FinoraTwin provides protected user access through an authentication system.

Core authentication functionality includes:

* User registration
* User login
* Password-based authentication
* Access control
* Protected application routes
* Refresh token support
* Session persistence

Authentication is integrated between the Flutter application and backend API.

---

# 🏢 Business Setup

FinoraTwin allows users to establish their business context before using the financial intelligence features.

Business-related functionality includes:

* Business information
* Business profile
* Financial context
* Business setup workflow
* Business-specific financial analysis

The business context allows financial information and analysis to be associated with the appropriate business.

---

# 📊 Financial Dashboard

The dashboard provides a centralized overview of the business's financial condition.

The dashboard is designed to bring important financial information together so that users can quickly understand the current state of their business.

It acts as the main entry point for financial monitoring and decision-making.

---

# ❤️ Financial Health

The Financial Health module evaluates the overall financial condition of the business.

It is designed to help users understand:

* Current financial condition
* Financial stability
* Important financial indicators
* Potential financial concerns
* Overall financial health

The purpose of this module is to convert financial data into a more understandable representation of business health.

---

# 💸 Transaction Management

FinoraTwin includes transaction management for recording and analyzing business financial activity.

Transactions form an important part of the platform because other financial intelligence features can use transaction data for analysis.

The transaction workflow includes:

```text
Transaction Data
       ↓
Persistent Storage
       ↓
Financial Processing
       ↓
Financial Analysis
       ↓
Insights
```

---

# 💰 Cash Pressure Analysis

The Cash Pressure module focuses on identifying situations where the business may experience financial pressure due to cash availability and financial obligations.

The feature is designed to help users understand:

* Cash availability
* Financial pressure
* Potential liquidity concerns
* Business cash position
* Areas requiring attention

This provides a more decision-oriented view than simply displaying account balances.

---

# 🔎 Financial Leak Detector

The Leak Detector is designed to identify potential areas where money may be unnecessarily leaving the business.

The system can analyze financial activity and highlight potential financial leaks or problematic spending patterns.

The general workflow is:

```text
Financial Transactions
        ↓
Pattern Analysis
        ↓
Potential Leak Detection
        ↓
Risk Signal
        ↓
User Insight
```

This helps business owners investigate areas that may negatively affect profitability or cash flow.

---

# 🏦 Capital Simulator

FinoraTwin includes a Capital Simulator for evaluating financial decisions involving business capital.

The simulator allows users to provide financial inputs and obtain calculated results that can help evaluate possible capital-related decisions.

The workflow is:

```text
Financial Inputs
       ↓
Capital Simulation
       ↓
Calculated Results
       ↓
Decision Support
```

This feature is designed to help users think about financial decisions before committing real resources.

---

# 📈 Scenario Analysis

The Scenarios module provides a structured way to evaluate possible future business situations.

Instead of looking only at historical data, users can explore possible scenarios and understand their potential financial implications.

```text
Current Financial State
          ↓
Future Scenario
          ↓
Financial Calculation
          ↓
Potential Outcome
          ↓
Decision Support
```

Scenario analysis helps users evaluate "what if" situations before making important financial decisions.

---

# 🎯 Financial Goals

FinoraTwin includes financial goal management to help users define and monitor business-oriented financial objectives.

Goals provide a structured way to connect financial planning with measurable targets.

The goal workflow can be represented as:

```text
Financial Goal
      ↓
Target Definition
      ↓
Progress Tracking
      ↓
Financial Monitoring
      ↓
Goal Achievement
```

---

# 🤖 AI Financial Copilot

The AI Copilot is one of the core intelligence components of FinoraTwin.

It is designed to provide users with AI-assisted financial explanations, insights, and decision support based on the available financial context.

The AI workflow is designed around:

```text
Business Financial Data
          ↓
Financial Context
          ↓
AI Processing
          ↓
Financial Explanation
          ↓
Recommendation
          ↓
User Decision
```

The purpose of the AI Copilot is not simply to provide generic chatbot responses.

It is intended to act as a financial assistant that understands the user's business context and helps explain financial situations in a more accessible way.

---

# 📄 Document & Financial Data Support

The backend includes document and document-chunk entities that provide a foundation for handling structured financial documents and their associated content.

This architecture can support financial information processing where larger documents or business records need to be represented and processed in smaller logical units.

```text
Financial Document
       ↓
Document Processing
       ↓
Document Chunks
       ↓
Financial Context
       ↓
AI / Analysis
```

---

# 💡 Recommendations

FinoraTwin includes a recommendation layer for storing and presenting financial recommendations generated from financial analysis.

Recommendations connect analysis with action.

```text
Financial Data
      ↓
Analysis
      ↓
Risk / Opportunity
      ↓
Recommendation
      ↓
Business Decision
```

This helps move the platform from passive financial tracking toward active financial decision support.

---

# 🧠 Core Financial Intelligence

The platform combines multiple financial intelligence capabilities:

```text
                 Financial Intelligence
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
 Financial Health   Risk Detection   Decision Support
          │              │              │
          ▼              ▼              ▼
   Cash Pressure    Leak Detector    Simulations
                                         │
                                         ▼
                                      Scenarios
                                         │
                                         ▼
                                     AI Copilot
```

---

# 🏗️ System Architecture

FinoraTwin follows a layered architecture separating the mobile application, API layer, domain logic, infrastructure, and persistent storage.

```text
┌───────────────────────────────────────┐
│            Flutter Client             │
│                                       │
│ UI + Navigation + State Management    │
│ Financial Features + Local Storage    │
└───────────────────┬───────────────────┘
                    │
                    │ HTTP / JSON
                    ▼
┌───────────────────────────────────────┐
│              API Layer                │
│            ASP.NET Core               │
│                                       │
│ Controllers                           │
│ DTOs                                  │
│ Middleware                            │
│ Authentication                        │
└───────────────────┬───────────────────┘
                    │
                    ▼
┌───────────────────────────────────────┐
│             Domain Layer              │
│                                       │
│ Entities                              │
│ Models                                │
│ Enums                                 │
│ Abstractions                          │
└───────────────────┬───────────────────┘
                    │
                    ▼
┌───────────────────────────────────────┐
│         Infrastructure Layer          │
│                                       │
│ Entity Framework Core                 │
│ Persistence                           │
│ Database Configuration                │
│ Migrations                            │
└───────────────────┬───────────────────┘
                    │
                    ▼
┌───────────────────────────────────────┐
│             PostgreSQL                │
│                                       │
│ Persistent Financial Data             │
└───────────────────────────────────────┘
```

The repository separates the backend into API, Domain, Infrastructure, and test projects, with database persistence handled through the Infrastructure layer.

---

# 🌐 API Architecture

The Flutter application communicates with the backend through RESTful APIs.

```text
Flutter Application
        │
        │ HTTP Request
        ▼
ASP.NET Core API
        │
        ▼
Controller
        │
        ▼
Business / Domain Logic
        │
        ▼
Infrastructure
        │
        ▼
PostgreSQL
        │
        ▼
API Response
        │
        ▼
Flutter Application
```

The backend currently exposes controller areas for:

* Authentication
* Administration
* AI
* Business
* Capital
* Financial operations
* Transactions

These controller areas reflect the major functional responsibilities of the backend.

---

# 🗄️ Data Architecture

FinoraTwin uses PostgreSQL as the persistent database layer.

The backend domain contains entities representing:

* Users
* Businesses
* Transactions
* Financial snapshots
* Loans
* Loan payments
* Simulations
* Recommendations
* Documents
* Document chunks
* Refresh tokens
* Audit logs

This structure provides a persistent foundation for financial analysis, business context, authentication, simulation, and recommendation workflows.

---

# 📱 Flutter Application Architecture

The Flutter application is organized into feature-based modules.

Major feature areas include:

```text
lib/
│
├── app_shell/
├── core/
├── data/
├── features/
│   ├── action_plan/
│   ├── admin/
│   ├── ai_copilot/
│   ├── auth/
│   ├── business_setup/
│   ├── capital_simulator/
│   ├── cash_pressure/
│   ├── dashboard/
│   ├── data_quality/
│   ├── explore/
│   ├── financial_health/
│   ├── funding/
│   ├── goals/
│   ├── leak_detector/
│   ├── onboarding/
│   ├── profile/
│   ├── scenarios/
│   ├── settings/
│   ├── splash/
│   └── transactions/
│
├── routing/
├── app.dart
└── main.dart
```

The repository follows this feature-oriented organization in the Flutter client.

---

# 🧩 Technology Stack

## 📱 Frontend

* Flutter
* Dart
* Flutter Riverpod
* GoRouter
* Dio
* HTTP
* Shared Preferences
* Flutter Secure Storage
* Drift
* SQLite
* FL Chart
* Flutter Markdown
* Freezed
* JSON Serialization

The Flutter project configuration includes libraries for state management, routing, networking, secure storage, local persistence, charts, and structured data handling.

---

## ⚙️ Backend

* ASP.NET Core
* .NET
* C#
* RESTful APIs
* Entity Framework Core
* DTO-based API communication
* Middleware
* Authentication
* Authorization

---

## 🗄️ Database

* PostgreSQL
* Entity Framework Core
* Database Migrations
* Persistent relational data storage

---

## 🤖 AI & Intelligence

* AI Financial Copilot
* Financial analysis
* Financial recommendations
* Scenario-based decision support
* Financial risk analysis
* AI-assisted explanations

---

## 🛠️ Development Tools

* Visual Studio Code
* Flutter SDK
* .NET SDK
* Git
* GitHub
* Android Emulator
* ADB
* Docker
* PostgreSQL
* Swagger / OpenAPI

---

# 📂 Backend Project Structure

```text
backend/
│
├── FinoraTwin.Api/
│   ├── Controllers/
│   ├── DTOs/
│   ├── Middleware/
│   ├── Properties/
│   ├── Seed/
│   ├── Program.cs
│   └── appsettings.json
│
├── FinoraTwin.Domain/
│   ├── Abstractions/
│   ├── Entities/
│   ├── Enums/
│   └── Models/
│
├── FinoraTwin.Infrastructure/
│   ├── Configurations/
│   ├── Migrations/
│   ├── Persistence/
│   └── AppDbContext.cs
│
├── FinoraTwin.Tests/
│
├── sql/
├── Dockerfile
└── FinoraTwin.slnx
```

The backend repository is separated into API, Domain, Infrastructure, and Tests projects, with SQL and deployment-related files alongside them.

---

# 🔄 End-to-End Application Flow

The complete FinoraTwin workflow can be represented as:

```text
                         User
                           │
                           ▼
                       Onboarding
                           │
                           ▼
                      Registration
                           │
                           ▼
                          Login
                           │
                           ▼
                    Business Setup
                           │
                           ▼
                       Dashboard
                           │
             ┌─────────────┼─────────────┐
             │             │             │
             ▼             ▼             ▼
       Transactions   Financial Health  Goals
             │             │
             ▼             ▼
       Financial Data  Risk Analysis
             │             │
             └───────┬─────┘
                     │
             ┌───────┼────────┐
             │       │        │
             ▼       ▼        ▼
      Cash Pressure  Leak    Capital
                     Detector Simulator
             │       │        │
             └───────┼────────┘
                     │
                     ▼
                  Scenarios
                     │
                     ▼
                 AI Copilot
                     │
                     ▼
                Recommendation
                     │
                     ▼
                Business Decision
```

---

# 🔐 Security

FinoraTwin includes security mechanisms across the application and backend layers.

Security-related areas include:

* User authentication
* Password protection
* Access tokens
* Refresh tokens
* Protected API endpoints
* Authorization
* Secure local storage
* Input validation
* Backend middleware
* Audit logging
* Secure configuration

Sensitive credentials and secrets should never be committed to the repository.

---

# 💾 Local Data & Offline Support

The Flutter application includes local persistence technologies such as Drift and SQLite, together with secure storage and connectivity handling.

This provides a foundation for:

* Local financial data handling
* Persistent application state
* Secure token storage
* Connectivity-aware application behavior
* Local-first workflows where appropriate

---

# 🧪 Testing & Verification

FinoraTwin includes a dedicated backend test project and Flutter test structure.

Testing areas include:

```text
Application
    ↓
UI Verification
    ↓
Feature Verification
    ↓
API Verification
    ↓
Backend Verification
    ↓
Database Verification
```

Important areas to verify include:

* [ ] Application starts successfully
* [ ] User registration works
* [ ] User login works
* [ ] Authentication state persists
* [ ] Business setup works
* [ ] Dashboard loads
* [ ] Transactions work
* [ ] Financial health works
* [ ] Cash pressure analysis works
* [ ] Leak detection works
* [ ] Capital simulation works
* [ ] Scenario analysis works
* [ ] Goals work
* [ ] AI Copilot responds
* [ ] Recommendations are displayed
* [ ] API communication works
* [ ] Database persistence works

---

# 🧪 API Testing

The backend can be tested through Swagger / OpenAPI during development.

API verification can include:

* Authentication endpoints
* Business endpoints
* Financial endpoints
* Transaction endpoints
* Capital endpoints
* AI endpoints
* Authorization behavior
* Request validation
* Response validation

---

# 🚀 Getting Started

## 1. Clone Repository

```bash
git clone https://github.com/mamun657/FinoraTwin.git
cd FinoraTwin
```

---

# 📱 Flutter Setup

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Check Flutter Environment

```bash
flutter doctor
```

---

## 4. Check Connected Devices

```bash
flutter devices
```

Or:

```bash
adb devices
```

---

# ⚙️ Backend Setup

## 5. Navigate to Backend

```bash
cd backend
```

---

## 6. Restore .NET Dependencies

```bash
dotnet restore
```

---

## 7. Run Backend API

```bash
dotnet run --project .\FinoraTwin.Api
```

The backend API can then be accessed through the configured local API address.

Swagger / OpenAPI can be used for API verification during development.

---

# 🗄️ Database

FinoraTwin uses PostgreSQL for persistent backend data.

The backend includes Entity Framework Core persistence and migrations.

```text
Flutter
   ↓
REST API
   ↓
ASP.NET Core
   ↓
Entity Framework Core
   ↓
PostgreSQL
```

The application can be configured to use a local PostgreSQL instance or a hosted PostgreSQL database depending on the environment.

---

# 📱 Run Flutter Application

From the project root:

```bash
flutter run
```

For an Android emulator, the API base URL should point to the backend host address accessible from the emulator.

Example:

```bash
flutter run -d <device-id>
```

---

# 🔄 Development Architecture

The complete development environment can be represented as:

```text
┌──────────────────────┐
│ Flutter Application  │
│      Android         │
└──────────┬───────────┘
           │
           │ REST API
           ▼
┌──────────────────────┐
│   ASP.NET Core API   │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Entity Framework Core│
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│      PostgreSQL      │
└──────────────────────┘
```

---

# 🎯 Project Objectives

The primary objectives of FinoraTwin are:

1. Build an intelligent financial management platform for small businesses
2. Provide a clear view of business financial health
3. Detect potential financial risks and leaks
4. Monitor cash pressure
5. Support capital and funding decisions
6. Allow users to simulate financial scenarios
7. Help users define and track financial goals
8. Provide AI-assisted financial insights
9. Convert financial data into actionable recommendations
10. Build a scalable architecture for future financial intelligence features

---

# 💼 Business Value

FinoraTwin is designed around the idea that financial software should not only record what happened but also help explain what is happening and what could happen next.

The platform provides:

```text
Financial Records
       +
Financial Analysis
       +
Risk Detection
       +
Simulation
       +
AI Assistance
       +
Recommendations
       =
Financial Decision Support
```

This allows small businesses to move from:

```text
"Here is my financial data."
```

toward:

```text
"What does my financial data mean?"
```

and ultimately:

```text
"What should I do next?"
```

---

# 🔮 Future Scope

Potential future improvements include:

* More advanced financial forecasting
* Automated financial reports
* Advanced cash-flow prediction
* Expanded AI financial reasoning
* More financial scenario models
* Automated alerts
* Advanced business analytics
* Financial document ingestion
* Improved recommendation personalization
* Advanced data quality analysis
* Multi-business support
* Cloud-based synchronization
* Enhanced financial dashboards
* More advanced risk scoring
* External financial data integrations

---

# 🧠 Design Principles

## Decision-Oriented

FinoraTwin focuses on turning financial information into decisions rather than simply displaying raw data.

## Modular

Financial capabilities are organized into separate feature modules such as Financial Health, Cash Pressure, Leak Detector, Capital Simulator, Scenarios, Goals, and AI Copilot.

## Secure

Authentication, protected API access, secure local storage, authorization, and audit-related functionality are incorporated into the architecture.

## Scalable

The separation between Flutter, API, Domain, Infrastructure, and PostgreSQL provides a foundation for future expansion.

## Maintainable

Feature-based Flutter organization and separated backend responsibilities make the system easier to develop and maintain.

---

# 📊 FinoraTwin at a Glance

| Area              | Function                                |
| ----------------- | --------------------------------------- |
| Authentication    | Secure user access                      |
| Business Setup    | Establish business context              |
| Dashboard         | Financial overview                      |
| Transactions      | Financial activity management           |
| Financial Health  | Overall financial condition             |
| Cash Pressure     | Liquidity and pressure analysis         |
| Leak Detector     | Potential financial leak identification |
| Capital Simulator | Capital decision simulation             |
| Scenarios         | Future what-if analysis                 |
| Goals             | Financial target management             |
| AI Copilot        | AI-assisted financial guidance          |
| Recommendations   | Action-oriented financial suggestions   |
| Documents         | Financial document support              |
| PostgreSQL        | Persistent financial data               |
| REST API          | Application communication               |

---

# 👨‍💻 Developer

**Mohammed Minul Islam**

Software Developer

---

# 📌 Project Summary

FinoraTwin is an AI-powered financial decision platform designed specifically around the financial challenges faced by small businesses.

The system connects:

```text
Business Data
      ↓
Transactions
      ↓
Financial Analysis
      ↓
Financial Health
      ↓
Risk Detection
      ↓
Cash Pressure
      ↓
Leak Detection
      ↓
Capital Simulation
      ↓
Scenario Analysis
      ↓
AI Copilot
      ↓
Recommendations
      ↓
Better Financial Decisions
```

The long-term vision of FinoraTwin is to create a financial intelligence platform that helps small businesses understand their current financial condition, evaluate future possibilities, identify risks, and make more informed business decisions.
