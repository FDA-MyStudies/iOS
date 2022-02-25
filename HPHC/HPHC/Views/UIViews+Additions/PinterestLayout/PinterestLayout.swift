/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
protocol PinterestLayoutDelegate {
  // 1. Method to ask the delegate for the height of the image
  func collectionView(_ collectionView: UICollectionView,
                      heightForPhotoAtIndexPath indexPath: IndexPath,
                      withWidth: CGFloat) -> CGFloat
  // 2. Method to ask the delegate for the height of the annotation text
  func collectionView(_ collectionView: UICollectionView,
                      heightForAnnotationAtIndexPath indexPath: IndexPath,
                      withWidth width: CGFloat) -> CGFloat
  
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
  
  // 1. Custom attribute
  var photoHeight: CGFloat = 0.0
  
  // 2. Override copyWithZone to conform to NSCopying protocol
  override func copy(with zone: NSZone?) -> Any {
    let copy = super.copy(with: zone) as! PinterestLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  // 3. Override isEqual
  override func isEqual(_ object: Any?) -> Bool {
    if let attributtes = object as? PinterestLayoutAttributes {
      if attributtes.photoHeight == photoHeight {
        return super.isEqual(object)
      }
    }
    return false
  }
}

class PinterestLayout: UICollectionViewLayout {
  // 1. Pinterest Layout Delegate
  var delegate: PinterestLayoutDelegate!
  
  // 2. Configurable properties
  var numberOfColumns = 2
  var cellPadding: CGFloat = 3.0
  
  // 3. Array to keep a cache of attributes.
  fileprivate var cache = [PinterestLayoutAttributes]()
  
  // 4. Content height and size
  fileprivate var contentHeight: CGFloat  = 0.0
  fileprivate var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return collectionView!.bounds.width - (insets.left + insets.right)
  }
  
  override class var layoutAttributesClass: AnyClass {
    return PinterestLayoutAttributes.self
  }
  
  override func prepare() {
    // 1. Only calculate once
    if cache.isEmpty {
      
      // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      var xOffset = [CGFloat]()
      for column in 0 ..< numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth )
      }
      var column = 0
      var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
      
      // 3. Iterates through the list of items in the first section
      for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
        
        let indexPath = IndexPath(item: item, section: 0)
        
        // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
        let width = columnWidth - cellPadding*2
        let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
        let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
        let height = cellPadding +  photoHeight + annotationHeight + cellPadding
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
        
        // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
        let attributes = PinterestLayoutAttributes(forCellWith: indexPath)
        attributes.photoHeight = photoHeight
        attributes.frame = insetFrame
        cache.append(attributes)
        
        // 6. Updates the collection view content height
        contentHeight = max(contentHeight, frame.maxY)
        yOffset[column] = yOffset[column] + height
        
        column = column >= (numberOfColumns - 1) ? 0 :  column + 1
      }
    }
  }
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Loop through the cache and look for items in the rect
    for attributes  in cache {
      if attributes.frame.intersects(rect ) {
        layoutAttributes.append(attributes)
      }
    }
    return layoutAttributes
  }
}
