import 'dart:js_interop';

@JS('eval')
external void eval(String code);

void removeLoadingIndicator() {
  try {
    eval('''
      const loadingContainer = document.getElementById("loading-container");
      if (loadingContainer) {
        loadingContainer.classList.add("fade-out");
        setTimeout(function() {
          loadingContainer.style.display = "none";
        }, 500);
      }
    ''');
  } catch (e) {
    // Fail silently
  }
}
