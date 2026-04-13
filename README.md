# task_management_app

A new Flutter project.

## Getting Started
Enhanced Features
1. Real-Time Search / Filter
A search bar sits above the task list and filters tasks by title instantly as you type. It works by storing the search query in local state and filtering the live Firestore stream results client-side — so it updates with every keystroke without making extra Firestore reads.
Why I chose it: Every real task management app needs search. As your list grows, scrolling through every task to find one becomes unusable. This feature also demonstrates an important Flutter pattern — layering local setState() filtering on top of a live cloud stream without interrupting the StreamBuilder pipeline. It shows the clear separation between local UI state and cloud data state.
2. Dark Mode (In-App Toggle)
The app includes a sun/moon icon button in the AppBar that instantly switches between light and dark themes. The theme state is managed at the MyApp level using a StatefulWidget and passed down via context.findAncestorStateOfType(), so any widget in the tree can trigger a theme change.
Why I chose it: Dark mode is a first-class expectation on Android. Implementing it as an in-app toggle rather than just following the system setting required understanding how to lift state above MaterialApp — which is a core Flutter architecture concept. It also exercises Material 3's ColorScheme system, showing how a single seed color generates a full accessible color palette for both light and dark themes automatically.