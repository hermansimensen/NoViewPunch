# NoViewPunch

Removes the viewpunch from landing in CS:GO. (Feels more like CSS or Momentum Mod)

## Requirements

* DHooks (for PlayerRoughLandingEffects hook)

## Showcase
Without plugin (left) - With plugin (right). You can notice the viewpunch, especially when looking at walls. This is completely dealt with in this plugin.
<img src="viewpunch.gif?raw=true" width="800px">

## What it does

* Suppresses the viewpunch from landing
* Disables the viewpunch from shooting
* Optionally sets custom models to remove landing animations (disabled by setting the convar nvp_custommodels to 0)
* Lets players toggle client-side prediction in-game resulting in perfect camera movement (!toggleprediction). This will only work well on players with low ping, as it relies on a good connection to the server.
* Cancels PlayerRoughLandingEffects, which stops some viewpunches from long falls. Note that CS:GO also does viewpunching on the client side, so sometimes, it will still punch the view for a fraction of a second, before it returns to normal.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)