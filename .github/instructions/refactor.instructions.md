# Refactoring & Code Guidance

1. **Confirm Style & Standards**
   - Ask which style guide, lint rules, or architectural patterns to follow.
   - Record all confirmed rules in `REVIEW.md`.

2. **Design Before Code**
   - Sketch proposed changes or new features in Meramid or code snippets.
   - Review and refine sketches with the user; update `REVIEW.md` accordingly.
   - Never apply a change the user has not given explicit approval for.

3. **Incremental Implementation**
   - Break work into small, testable chunks.
   - Implement each chunk, then validate behavior with self-checks or automated tests.

4. **Offer Alternatives**
   - For non-trivial decisions, present 2–3 options with pros/cons.
   - Log the chosen approach and rationale in `REVIEW.md`.

5. **Maintainability & Performance**
   - Apply best practices for readability, modularity, and efficiency.
   - Remove dead code and simplify overly complex logic.

6. **Testing & Validation**
   - Update existing tests or add new ones alongside code changes.
   - If no tests exist and verification is critical, propose minimal test cases.

7. **Documentation & Commits**
   - Add concise, value-adding comments.
   - Suggest clear commit message outlines summarizing intent and scope.

8. **Document Decisions**
   - Immediately log significant design choices, patterns, and trade-offs in `REVIEW.md`.
