# Current Task

I at the final stages of this app, but I have made a drastic change to it. I am abandoning the idea of storing health data locally due to privacy concerns. I will be only using apple health for health data.

I still want my app to add convenient way to create entries, so I will need to implement healthKit craetion, or disable adding for now.

But in general, here's my problem: my view's regarding health data are a mess. So many layers, abstractions, structures, etc. that I feel can be simplified greatly.

Some things to keep in mind:

I still need to know whether the data is internal or not, so that I can delete them or edit them whenever we implement that

I added the id just for convience, otherwise, i don't care for it.

Even units, I now should just rely on Apple Health's preferred units: see https://developer.apple.com/documentation/healthkit/hkhealthstore/preferredunits(for:completion:)
You MUST read the above.
The thing with units tho is that I still want to support inputting data in any unit, the way my measurmentField works. This is very useful. And I plan on having my charts also use that system to choose a unit for things like budgets or wtvr I'll be adding.

The data service for example, the wrapper there, I feel is becoming redundent. Maybe it is worth rethinking our interfaces and services.
The goal is reducing complexity. With this change, some features might not make sense anymore.

Another thing to remember, I might support tracking non-healthkit data in the future. I believe if we following native patterns that the frameworks we use are already using, then this should be supported naturally. But keep it in mind.

My views now are a big problem.

The goal here is to streamline two development paths:

- supporting new data types: this means defining all things necessary to support a new type minimally and together. for now, this is the path as I see it:
    - create a model
    - add it to HealthDataModel enum (we should use this to support things like switch statements on health data, to have the compiler check if a new type is fully implemented)
    - define a unit if it needs a new one (I'm not sure how this will work with the new HealthKit preferred units)
    - define a query for it to define how it is fetched from healthkit (or maybe swiftdata in the future)
    - then I would like to have a single file per type to define how they look, from icons, colors, etc. Similar to the current Views/Records but hopefully much cleaner and better organized (file per type, and remember, compiler checks are wanted)
    - define new Views/UI tokens if needed, but I want to keep this minimal (it maps to external assets)

- defining new charts that can be used on any data type(s). For example, a budget chart that has a budget, period (day, week, month, etc..), and it would show things like progress per day, or links to display a list of entries for that day, etc etc.
    - I want this to also be as easily as:
    - define how the chart looks, accepting wtvr it needs to display (for example, a budget, the record type, etc..)
        - it define how it looks as a widget (preview) that navigated to a screen that shows the chart in detail
        - the details allow the user to see different periods, and wtvr the chart wants to show
    - go use it in my dashboard, choosing what data types it should work on, using their colors and definitions and all


Things like the detailed row and the measurement field are working very well, they just might need a sloght interface change depending on what design we come up with.
Other things need complete redesign, this is especially the DataView and everything it uses.

This is a design phase. we just gotta make sure your REVIEW.md provides all the details necesary to refactor the code. Image this as a SW architecture meeting and the REVIEW.md is a whiteboard we will provide to developers to implement
