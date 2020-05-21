# todo

## easy
### Extra pain
- Improve color contrasts (line-chart, buy-sell rates, backgrounds)
- Refactor color variables to use **primary** **secondary** paradigm and the variants made by applying opacity
- Chance favicon.ico
- Pressing anywhere to cancel demo is not intuitive


## medium
- Export data
- Set form dates with sensible defaults, specially for hours
- Hide **what to show** when dates are null
- Improve page rating - Chrome/lighthouse
- Save ratehashes into LocalStorage
- Add mobile gestures to open and close rate settings
- Sustitute ratehashes with json zipped? [json-url](https://github.com/masotime/json-url)
- Add analytics to API endpoints
- Refactor
- When a **Rate** is loaded, subsequent fetches should only show a tiny Loader, instead of unmounting current rate
### Extra pain
- Flags fallback rendering (using css?) https://github.com/lipis/flag-icon-css
- Add translations
- Branding


## hard
- Move to netlify
- Implement SSR or Sapper
### Extra pain
- Sustitute moment.js and Chart.js with (Pancake | OWID)?
- Improve UI to choose currencies (Maybe flags around a circle with selected flag in the middle)

# Bug
- Rate refreshes when opening form when browser does not support datetime input
- (Nerio) Inputs don't allow entering big numbers, when entering `150000` it resets to `15`
- Back: Fix failures in obtaining rates


# Done
- Fix **latest rate** after choosing a date
- use class:classname syntax
- Close form from the top
- Fix hover and cursor in icons
- remove unnecessary libraries (hammer, popper, zoom-plugin)
- Move settings to a collapsable div, as a bar button at the bottom of each rate
- convert tabbed-files to spaces
- Add hover style to settings button bar
- Add transition to collapsing elements