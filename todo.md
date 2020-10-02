# todo

## MUST DO
- Fix external preview links - Implement Open Graph <https://ogp.me/>
- Move DB closer to vercel's server
- Fix: Catch failures in fetch, e.g. like when date is in the future or there is no data between those dates
- Methodology: Link to or Describe how calculations are made
- Analytics for default and casual rates.
- Get prices from NodeJs
- Remove Demo button
- Color contrasts (line-chart, buy-sell rates, backgrounds)
### Done
- Improve page rating - Chrome/lighthouse
- Heavy libraries: Remove libraries from template or use them from a npm package (https://css.gg/search - https://github.com/astrit/css.gg#get-started)
- Fix: vercel deploy
- Fix: `HiddenInputDate` doesn't work in chrome anymore

## easy
- Share button, general layout
- Save to bookmark
- Button to invert currencies position
- Caché API responses until next price update
### Extra pain
- Refactor color variables to use **primary** **secondary** paradigm and its variants made by applying opacity
- Pressing anywhere to cancel demo is not intuitive

## medium
- Share button, specific rate
- Export data
- Add mobile gestures to open and close rate settings
- Improve transitions for opening and closing `Form`
- New page: table-like to show all rates simultaneously
- Serverless Function does not handle well a Pool connection https://vercel.com/guides/deploying-next-and-mysql-with-vercel#step-2:-set-up-your-project
### Extra pain
- Add translations
- Create favicon.ico
- Branding

## hard
- Implement Redis or cache for hot data <- maybe not, seems to cost as much as a DB
- Implement typescript
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
- Moved to Vercel --- Move to netlify
- Sapper --- Implement SSR or Sapper
- Had to do it anyway by implementing Sapper --- Refactor
- Made a custom format and encoded in base64 --- Sustitute ratehashes with json zipped? [json-url](https://github.com/masotime/json-url)
- N/A --- When a **Rate** is loaded, subsequent fetches should only show a tiny Loader, instead of unmounting current rate
- Check rates inconsistency - There was no inconsistency. Turns out that a simple average is not a good middle point, but the **geometric mean** would be, but it wouldn't be intuitive for users `--_(:/)_--`
- Flags fallback rendering (using css?) https://github.com/lipis/flag-icon-css
- Loader: Show rate is loading
- Move back to NodeJS
