
## Story 1.2 - ProfileDetailView Deferred Items (2026-03-28)

- **currentUserId empty string in DI**: ProfileDetailViewModel receives `currentUserId: ""`. Project-wide issue — DiscoverView also hardcodes user ID. Needs proper auth session service injected into coordinators/VMs.
- **Concurrent swipe calls**: No debouncing/throttling on swipe actions. Same pattern exists in DiscoverViewModel. Should add `guard !isSwiping` state.
- **Match alert "Nhắn tin" does nothing**: Tapping "Send message" in match alert only dismisses. Needs navigation to chat screen. Same gap exists in DiscoverView match alert.
- **AC#3 Distance display**: Profile entity has `location` (lat/lon/city) but no `distance` field. Displaying actual distance requires computing from current user's location or adding a distance field to the API response. CardView also only shows city.
- **Navigation from CardView to ProfileDetail**: DiscoverView/CardView have no tap gesture to trigger `coordinator.showProfileDetail(profileId:)`. This entry point needs a separate story.
