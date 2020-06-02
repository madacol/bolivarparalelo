
// Svelte store backed by window.localStorage
// Persists store's data locally
import {writable as internal, get} from 'svelte/store'

// wraps a regular writable store
function writable(key, initialValue) {
  // create an underlying store
  const store = internal(initialValue)
  const {subscribe, set} = store
  // get the last value from localStorage
  const json = localStorage.getItem(key)
  
  // use the value from localStorage if it exists
  if (json) {
    set(JSON.parse(json))
  }
  
  // return an object with the same interface as svelte's writable()
  return {
    // capture set and write to localStorage
    set(value) {
      localStorage.setItem(key, JSON.stringify(value))
      set(value)
    },
    // capture updates and write to localStore
    update(cb) {
      const value = cb(get(store))
      this.set(value)
    },
    // punt subscriptions to underlying store
    subscribe
  }
}

// source: https://gist.github.com/joshnuss/aa3539daf7ca412202b4c10d543bc077
/*
LICENSE:

Copyright 2020 Joshua Nussbaum

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/**********
 * Stores *
 **********/

export const hashLS = writable("hashLS", "");