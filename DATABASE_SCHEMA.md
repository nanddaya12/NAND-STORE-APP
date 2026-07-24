# Database Schema Document

This document lists the schema fields, storage keys, and JSON representations configured in the **NAND Store** application.

## 1. Preferences Schema (`shared_preferences`)

| Key | Data Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `app_theme_mode` | String | `'light'` | Selected theme mode (`light`/`dark`). |
| `app_language` | String | `'en'` | Active locale string. |
| `app_currency` | String | `'USD'` | Rendered currency type. |
| `app_notifications_enabled` | Boolean | `true` | Push notification status toggles. |
| `app_is_first_launch` | Boolean | `true` | Welcome onboarding controller check. |
| `app_last_sync_timestamp` | Integer | `0` | Epoch timestamp of last successful API sync. |
| `db_schema_version` | Integer | `2` | Database version check value. |

---

## 2. Hive Data Box Key-Value Records

### 2.1 Products Catalog (`products` box)
*   **Key**: Product ID (String)
*   **Value Payload JSON**:
    ```json
    {
      "id": "p1",
      "name": "X-1 Pro Headphones",
      "description": "High-end wireless noise-cancelling headphones",
      "price": 299.99,
      "rating": 4.8,
      "category": "Electronics",
      "specs": {
        "Battery Life": "40 Hours"
      }
    }
    ```

### 2.2 Cart Cache (`cart` box)
*   **Key**: Composite key representing `productId_finish_size` (String)
*   **Value Payload JSON**:
    ```json
    {
      "product": { "id": "p1", "price": 299.99 },
      "quantity": 2,
      "selectedFinish": "Matte Black",
      "addedCost": 0.0
    }
    ```
