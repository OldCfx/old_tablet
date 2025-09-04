# 🗂️ old_tablet

`old_tablet` is an immersive FiveM script that allows players to view web links directly in-game via a tablet.

## ✨ Features

*   **Customizable Links**: Assign a unique web link to each individual tablet.
*   **Persistence**: Tablet links are saved and remain permanent, even after server restarts.
*   **Immersive Animations**: Enjoy a smooth and realistic animation when players use a tablet.
*   **Easy Modification**: Players can change a tablet's link at any time directly in-game.
*   **Improved Compatibility**: Automatically transforms certain links into embeds (where possible) for better integration and display.

## 🔗 Dependencies

For `old_tablet` to function correctly, you need to have the following scripts installed and started on your server:

*   [**ox_inventory**](https://github.com/overextended/ox_inventory)
*   [**ox_lib**](https://github.com/overextended/ox_lib)

## 🚀 Installation

Follow these steps to install `old_tablet` on your FiveM server:

1.  **Download the script**:
    *   Clone this Git repository or download the latest version from the releases page.
    *   Rename the downloaded folder to `old_tablet` (if it isn't already).

2.  **Place the folder**:
    *   Place the `old_tablet` folder inside your server's `resources/` directory.

3.  **Add to `server.cfg`**:
    *   Open your `server.cfg` file.
    *   Add the following line to ensure the script starts:
        ```cfg
        ensure old_tablet
        ```

## ⚙️ Configuration (ox_inventory)

For the tablet to be usable in-game, you need to add the `tablet` item to your `ox_inventory` data file.

1.  **Open `ox_inventory/data/items.lua`**.
2.  Add the following entry to your items table:

    ```lua
    ['tablet'] = {
        label = 'Tablet',
        weight = 500,
        stack = false,
        close = true,
        consume = 0,
        server = {
            export = "old_tablet.tablet", 
        },
        buttons = {
            {
                label = 'Modify Link', 
                action = function(slot)
                    exports.old_tablet:editLink(slot) 
                end
            },
        }
    },
    ```

## 🎮 In-Game Usage

### Obtaining a Tablet

*   Once configured in `ox_inventory`, you can give players a tablet via an admin command (e.g., `/giveitem [PLAYER_ID] tablet 1`) or through an in-game shop.

### Viewing a Link

1.  Open your inventory.
2.  Use the tablet item.
3.  The tablet will animate and display the link currently assigned to it.

### Modifying a Link

1.  Open your inventory.
2.  **Right-click** on the "Tablet" item.
3.  Select the "Modify Link" option.
4.  An `ox_lib` prompt will appear, asking you to enter the new URL.
5.  Enter the link and confirm. The new link will be saved to this specific tablet.

---
