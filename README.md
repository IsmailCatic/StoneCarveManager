# 🪨 StoneCarve Manager

StoneCarve Manager is an information system for a stone carving workshop that enables digitalization of the ordering process, catalog and portfolio management, order tracking, custom orders, service requests, payments, and business analytics.

The system includes a **desktop application** for administrators and employees, a **mobile application** for customers, and a **backend** developed in ASP.NET Core.

---

# 🚀 Getting Started

## 🔹 Backend Setup (Docker)

1. Clone the StoneCarveManager repository.

2. Navigate to the cloned repository and run:

```bash
docker compose up --build

Wait until all services (WebAPI, SQL Server, RabbitMQ, Email Service) start successfully. ⏳

The API will be available at:
http://localhost:8080

Swagger documentation:
http://localhost:8080/swagger

RabbitMQ Management UI:
http://localhost:15672 (guest/guest)

🔹 Desktop Application (Admin/Employee)

Extract the archive containing the desktop build.

Inside the Release folder, run:
stonecarve_manager_desktop.exe

Log in using the admin or employee credentials (see below).

🔹 Mobile Application (Users)

Before installation, ensure that an older version of the app is not installed on the emulator/device. If it is → uninstall it.

Extract the archive containing the mobile build.

Inside the flutter-apk folder, locate:
app-release.apk
Drag it onto the emulator or install it on a physical device.

Launch the application and log in using the test credentials (see below).

🔐 Login Credentials
Administrator (Desktop)
Field	Value
Username	admin1@stonecarve.com
Password	Admin@1234

Employee (Desktop)

Field	Value
Username	employee1@stonecarve.com
Password	Employee@1234
User (Mobile Application)

Field	Value
Username	user1@stonecarve.com
Password	User@1234

💳 Stripe Testing

For testing payments in the mobile application, use the following test card details:

Field	Value
Card Number	4242 4242 4242 4242
Expiry Date	Any future date
CVC	Any 3-digit number
ZIP Code	Any 5-digit number
📩 RabbitMQ Integration

StoneCarve Manager uses a RabbitMQ microservice for automatic email notifications in the following scenarios:

New user registration via the mobile application

Password reset — a 6-digit verification code is sent to the user via email

Order status change — users receive email notifications when the status of their order changes

✨ Key Features
📱 Mobile Application (Users)

Browse stone product catalog with filtering and sorting

View completed project portfolio

Recommendation system (content-based recommender using cosine similarity)

Shopping cart and checkout with Stripe integration

Service requests ordering

Custom orders with sketch upload

Real-time order status tracking

Product favorites

Leave reviews for completed orders

Blog with categories

FAQ section

User profile management

Password reset via verification code

🖥️ Desktop Application (Admin/Employees)

Dashboard with business analytics (revenue, orders, users)

Full CRUD operations for products, categories, and materials

Product lifecycle state machine
(draft → active → service/portfolio → hidden)

Order management and employee assignment

Progress image tracking for custom/service orders

User and role management (Admin, Employee, User)

Payment and refund management (full and partial refunds)

Analytics:

Revenue trends

Top products

Category performance

Employee performance

Customer and review statistics

Blog management (posts and categories)

FAQ management

## 🛠️ Technologies

| Category | Technology |
|----------|------------|
| Backend | ASP.NET Core 8 (C#), Entity Framework Core |
| Frontend | Flutter (desktop & mobile) |
| Database | SQL Server 2022 |
| Authentication & Authorization | JWT (JSON Web Tokens) |
| Validation | FluentValidation |
| Object Mapping | Mapster |
| Message Broker | RabbitMQ |
| Email | MailKit / MimeKit (Gmail SMTP) |
| Payments | Stripe |
| Image Storage | Azure Blob Storage |
| Containerization | Docker / Docker Compose |
| Version Control | Git |


📌 Note

This project was developed as part of the course Software Development II at the Faculty of Information Technologies Mostar.
