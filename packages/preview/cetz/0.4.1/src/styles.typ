#import "util.typ"

#let default = (
  fill: none,
  fill-rule: "non-zero",
  stroke: black + 1pt,
  radius: 1,
  /// Bezier shortening mode:
  ///   - "LINEAR" Moving the affected point and it's next control point (like TikZ "quick" key)
  ///   - "CURVED" Preserving the bezier curve by calculating new control points
  shorten: "LINEAR",
  
  // Allowed values:
  //   - none
  //   - Number
  //   - Array: (y, x), (top, y, bottom), (top, right, bottom, left)
  //   - Dictionary: (top:, right:, bottom:, left:)
  padding: none,
  mark: (
    scale: 1,         // A factor that is applied to length, width, and inset.
    length: .2cm,     // The size of the mark along its direction
    width: 0.15cm,    // The size of the mark along the normal of its direction
    inset: .05cm,     // The inner length of some mark shapes, like triangles and brackets
    sep: .1cm,        // The distance between multiple marks along their path
    pos: none,        // Position override on the path (none, number or path-length ratio)
    offset: 0,        // Mark extra offset (number or path-length ratio)
    start: none,      // Mark start symbol(s)
    end: none,        // Mark end symbol(s)
    symbol: none,     // Mark symbol
    xy-up: (0, 0, 1), // Up vector for 2D marks
    z-up: (0, 1, 0),  // Up vector for 3D marks
    stroke: auto,
    fill: auto,
    slant: none,      // Slant factor - 0%: no slant, 100%: 45 degree slant
    harpoon: false,
    flip: false,
    reverse: false,
    /// Max. number of samples to use for calculating curve positions
    /// a higher number gives better results but may slow down compilation.
    position-samples: 20,
    /// Index of the mark the path should get shortened to, or auto
    /// to shorten to the last mark. To apply different values per side,
    /// set the default to `0` and to `auto` for the mark you want to
    /// shorten the path to. Set to `none` to disable path shortening.
    shorten-to: auto,
    /// Apply shape transforms for marks. This is not honored per mark, but
    /// for all marks on a path. If set to false, marks get placed after the
    /// shape they are placed on got transformed, they appear "flat" or two-dimensional.
    transform-shape: false,
    /// Mark anchor used for placement
    /// Possible values are:
    ///   - "tip"
    ///   - "center"
    ///   - "base"
    anchor: "tip",
  ),
  circle: (
    radius: auto,
    stroke: auto,
    fill: auto
  ),
  group: (
    padding: auto,
    fill: auto,
    stroke: auto
  ),
  line: (
    mark: auto,
    fill: auto,
    fill-rule: auto,
    stroke: auto,
  ),
  bezier: (
    stroke: auto,
    fill: auto,
    fill-rule: auto,
    mark: auto,
    shorten: auto,
  ),
  catmull: (
    tension: .5,
    mark: auto,
    shorten: auto,
    stroke: auto,
    fill: auto,
    fill-rule: auto,
  ),
  hobby: (
    /// Curve start and end omega (curlyness)
    omega: (0,0),
    mark: auto,
    shorten: auto,
    stroke: auto,
    fill: auto,
    fill-rule: auto,
  ),
  rect: (
    /// Rect corner radius that supports the following types:
    /// - <radius>: Same x and y radius for all corners
    /// - (west: <radius>, east: <radius>, north: <radius>, south: <radius>,
    ///    north-west: <radius>, north-east: <radius>, south-west: <radius>, south-east: <radius>,
    ///    rest: <radius: 0>)
    ///
    /// A radius can be either a number, a ratio or a tuple of numbers or ratios.
    /// Ratios represent a value relative to the rects height or width.
    /// E.g. the radius `50%` is equal to `(50%, 50%)` and represents a x and y radius
    /// of 50% of the rects width/height.
    radius: 0,
    stroke: auto,
    fill: auto,
  ),
  arc: (
    // Supported values:
    //   - "OPEN"
    //   - "CLOSE"
    //   - "PIE"
    mode: "OPEN",
    update-position: true,
    mark: auto,
    stroke: auto,
    fill: auto,
    radius: auto
  ),
  polygon: (
    radius: auto,
    stroke: auto,
    fill: auto,
    fill-rule: auto,
  ),
  n-star: (
    radius: auto,
    stroke: auto,
    fill: auto,
    // Connect inner points of the star
    show-inner: false,
  ),
  content: (
    padding: auto,
    // Supported values
    //   - none
    //   - "rect"
    //   - "circle"
    frame: none,
    fill: auto,
    stroke: auto,
    // Apply canvas scaling to content
    auto-scale: false,
  ),
)

/// You can use this to combine the style in `ctx`, the style given by a user for a single element and an element's default style. 
///
/// `base` is first merged onto `dict` without overwriting existing values, and if `root` is given it is merged onto that key of `dict`. `merge` is then merged onto `dict` but does overwrite existing entries, if `root` is given it is merged onto that key of `dict`. Then entries in `dict` that are {{auto}} inherit values from their nearest ancestor and entries of type {{dictionary}} are merged with their closest ancestor. 
/// ```typ example
/// #let dict = (
///   stroke: "black",
///   fill: none,
///   mark: (stroke: auto, fill: "blue"),
///   line: (stroke: auto, mark: auto, fill: "red")
/// )
/// #cetz.styles.resolve(dict, merge: (mark: (stroke: "yellow")), root: "line")
/// ```
/// The following is a more detailed explanation of how the algorithm works to use as a reference if needed. It should be updated whenever changes are made.
/// Remember that dictionaries are recursively merged, if an entry is any other type it is simply updated. (dict + dict = merged dict, value + dict = dict, dict + value = value)
/// First if `base` is given, it will be merged without overwriting values onto `dict`. If `root` is given it will be merged onto that key of `dict`.
/// Each level of `dict` is then processed with these steps. If `root` is given the level with that key will be the first, otherwise the whole of `dict` is processed.
/// + Values on the corresponding level of `merge` are inserted into the level if the key does not exist on the level or if they are not both dictionaries. If they are both dictionaries their values will be inserted in the same stage at a lower level.
/// + If an entry is `auto` or a dictionary, the tree is travelled back up until an entry with the same key is found. If the current entry is `auto` the value of the ancestor's entry is copied. Or if the current entry and ancestor entry is a dictionary, they are merged with the current entry overwriting any values in it's ancestors.
/// + Each entry that is a dictionary is then resolved from step 1. 
///
/// ```typc example
/// get-ctx(ctx => {
///   // Get the current "mark" style
///   content((0,0), [#cetz.styles.resolve(ctx.style, root: "mark")])
/// })
/// ```
///
/// - dict (style): Current context style from `ctx.style`.
/// - merge (style): Style values overwriting the current style. I.e. inline styles passed with an element: `line(.., stroke: red)`.
/// - root (none, str, array): Style root element name or list of nested roots (`("my-package", "my-element")`).
/// - base (none, style): Style values to merge into `dict` without overwriting it.
/// -> style
#let resolve(dict, root: none, merge: (:), base: (:)) = {
  let resolve(dict, ancestors, merge) = {
    // Merge. If both values are dictionaries, merge's values will be inserted at a lower level in this step.
    for (k, v) in merge {
      if k not in dict or not (type(v) == dictionary and type(dict.at(k)) == dictionary) {
        dict.insert(k, v)
      }
    }

    // For each entry that is a dictionary or `auto`, travel back up the tree until it finds an entry with the same key.
    for (k, v) in dict {
      let is-dict = type(v) == dictionary
      if is-dict or v == auto {
        for ancestor in ancestors {
          if k in ancestor {
            // If v is auto and the ancestor's value is not auto, update v.
            if ancestor.at(k) != auto and v == auto {
              v = ancestor.at(k)
            // If both values are dictionaries, merge them. Values in v overwrite its ancestor's value.
            } else if is-dict and type(ancestor.at(k)) == dictionary {
              v = util.merge-dictionary(ancestor.at(k), v)
            }
            // Retain the updated value. Because all of the ancestors have already been processed even if a v is still auto that just means the key at the highest level either is auto or doesn't exist.
            dict.insert(k, v)
            break
          }
        }
      }
    }

    // Record history here so it doesn't change.
    ancestors = (dict,) + ancestors
    // Because only keys on this level have been processed, process all children of this level.
    for (k, v) in dict {
      if type(v) == dictionary {
        dict.insert(k, resolve(v, ancestors, merge.at(k, default: (:))))
      }
    }
    return dict
  }

  if base != (:) {
    if root != none {
      if type(root) != array {
        root = (root,)
      }
      let a = (:)
      for key in root.rev() {
        a.insert(key, base)
        base = a
        a = (:)
      }
    }
    dict = util.merge-dictionary(dict, base, overwrite: false)
  }

  let d = if root == none {
    dict
  } else if type(root) == array {
    root.fold(dict, (d, k) => d.at(k))
  } else {
    dict.at(root)
  }

  return resolve(
    d,
    if root != none {(dict,)} else {()},
    merge
  )
}
