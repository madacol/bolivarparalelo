# todo

## easy
- Share button, general and specific rate
- Save to bookmark
- Remove Demo button
- Link to methodology
### Extra pain
- Improve color contrasts (line-chart, buy-sell rates, backgrounds)
- Refactor color variables to use **primary** **secondary** paradigm and the variants made by applying opacity
- Pressing anywhere to cancel demo is not intuitive


## medium
- Custom analytics for default and casual rates.
- Export data
- Add mobile gestures to open and close rate settings
- Sustitute ratehashes with json zipped? [json-url](https://github.com/masotime/json-url)
- Add analytics to API endpoints
- Refactor
- When a **Rate** is loaded, subsequent fetches should only show a tiny Loader, instead of unmounting current rate
### Extra pain
- Flags fallback rendering (using css?) https://github.com/lipis/flag-icon-css
- Add translations
- Create favicon.ico
- Branding


## hard
- Move DB https://aws.amazon.com/rds/aurora/serverless/
- Implement Redis or cache for hot data <- maybe not, seems to cost as much as a DB
- Move to netlify
- Move back to NodeJS
- Implement SSR or Sapper
- Improve page rating - Chrome/lighthouse
### Extra pain
- Sustitute moment.js and Chart.js with (Pancake | OWID)?
- Improve UI to choose currencies (Maybe flags around a circle with selected flag in the middle https://stackoverflow.com/questions/12813573/position-icons-into-circle)


# Bugs
- (Nerio) Inputs don't allow entering big numbers, when entering `150000` it resets to `15`
- Back: Fix failures in obtaining rates
## Fixed
- Rate refreshes when opening form when browser does not support datetime input


# Done
- Fix **latest rate** after choosing a date
- use class:classname syntax
- Close form from the top
- Fix hover and cursor in icons
- remove unnecessary libraries (hammer, popper, zoom-plugin)
- Move settings to a collapsable div, as a bar button at the bottom of each rate
- convert tabbed-files to spaces
- Save ratehashes into LocalStorage
- Add hover style to settings button bar
- Add transition to collapsing elements
- Set form dates with sensible defaults, specially for hours
- Hide **what to show** when dates are null
