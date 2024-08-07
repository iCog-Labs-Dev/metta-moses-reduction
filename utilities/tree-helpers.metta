;; -----------------------------------
;; -----------------------------------
;; -------- function to build a tree of type "Tree" from an expression
;; -----------------------------------
;; -----------------------------------

(= (buildTree $expr) 
  (case $expr
    (
      ( (AND $a $b) (TreeNode (Value Nil False AND) Nil (Cons (buildTree $a) (Cons (buildTree $b) Nil))) )
      ( (OR $a $b) (TreeNode (Value Nil False OR) Nil (Cons (buildTree $a) (Cons (buildTree $b) Nil))))
      ( (NOT $x) (TreeNode (Value Nil False NOT) Nil (Cons NilNode (Cons (buildTree $x) Nil))))
      ( $symbol (TreeNode (Value $symbol False LITERAL) Nil Nil))
    )
  )
)

;; -----------------------------------
;; -----------------------------------
;; -------- function to build a tree with a root node of "ROOT"
;; -----------------------------------
;; -----------------------------------

(= (buildTreeWithRoot $expr)
  (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (buildTree $expr) Nil)))
)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get the right or left child
;; -----------------------------------
;; -----------------------------------

(:getChild (-> Tree Location Tree))
(= (getChild (TreeNode $nodeValue $guardSet Nil) $opt) NilNode)
(= (getChild (TreeNode $nodeValue $guardSet (Cons $l $xs)) L) $l)
(= (getChild (TreeNode $nodeValue $guardSet (Cons $l Nil)) R) NilNode)
(= (getChild (TreeNode $nodeValue $guardSet (Cons $l (Cons $r $xs))) R) $r)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get node children
;; -----------------------------------
;; -----------------------------------

(:getChildren (-> Tree (List Tree)))
(= (getChildren (TreeNode $nodeVal $guardSet $children)) $children)

;;A function to get node children at a given index
(:getChildAt (-> Tree Number Tree))
(= (getChildAt (TreeNode $nodeValue $guardSet Nil) $i) NilNode)

(= (getChildAt (TreeNode $nodeValue $guardSet (Cons $x $xs)) $i)
    ; (Cons $x $xs)
    (if (== Nil (index $i (Cons $x $xs)))
        NilNode
        (index $i (Cons $x $xs))
    )
)
;; -----------------------------------
;; -----------------------------------
;; -------- a function to get guardset
;; -----------------------------------
;; -----------------------------------

(:getGuardSet (-> Tree TreeList))
(= (getGuardSet (TreeNode $nodeValue $guardSet $children)) $guardSet)

;; -----------------------------------
;; -------- updateChild
;; -------- Given a binary tree node and position (left, right) indicating which child to update, replace it's left or right child with the given node.
;; -----------------------------------
;; -----------------------------------

;; (node location (L or R) newNode)
(:replaceChild (-> Tree Tree Location Tree))
(= (replaceChild (TreeNode $nodeValue $guardSet Nil) L) 
  (TreeNode $nodeValue $guardSet (Cons $newNode Nil))
)
(= (replaceChild (TreeNode $nodeValue $guardSet (Cons $l $xs)) $newNode L)
  (TreeNode $nodeValue $guardSet (Cons $newNode $xs))
)
(= (replaceChild (TreeNode $nodeValue $guardSet (Cons $l Nil) R))
  (TreeNode $nodeValue $guardSet (Cons $l (Cons $newNode Nil)))
)
(= (replaceChild (TreeNode $nodeValue $guardSet (Cons $l (Cons $r $xs))) $newNode R)
  (TreeNode $nodeValue $guardSet (Cons $l (Cons $newNode $xs)))
)

;; replace child of a node goven an index
(:replaceChildAt (-> Tree Tree Number Tree))
(= (replaceChildAt (TreeNode $nodeValue $guardSet $children) $newNode $i)
    (TreeNode $nodeValue $guardSet (replaceAtIndex $i $newNode $children))
)
;; -----------------------------------
;; -------- Append Children
;; -------- Given a node and a tree, append the tree to the node's children.
;; -----------------------------------
;; -----------------------------------


(:appendChild (-> Tree Tree Tree))
(= (appendChild (TreeNode $nodeValue $guardSet $children) $child)
  (TreeNode $nodeValue $guardSet (Cons $children $child))
)


(:isNodeEqual (-> Tree Tree Bool))
(= (isNodeEqual Nil Nil) False)
(= (isNodeEqual (TreeNode $nodeValue $guardSet $children) Nil) False)
(= (isNodeEqual Nil (TreeNode $nodeValue $guardSet $children)) False)
(= (isNodeEqual 
    (TreeNode $nodeValue1 $guardSet1 $children1) 
    (TreeNode $nodeValue2 $guardSet2 $children2)
   )
  (== $nodeValue1 $nodeValue2)
)

;;function to check if a tree is member of a treelist
(:treeIsMember (-> Tree (List Tree) Bool))
(= (treeIsMember $x $list)
   (memberWith isNodeEqual $x $list)
)

;;function to return the intersection of two treelists
(:treeIntersection (-> (List Tree) (List Tree) (List Tree)))
(= (treeIntersection $list1 $list2)
    (case $list1
    (
        (Nil Nil)
        ((Cons $h $t) 
         (if (treeIsMember $h $list2) 
            (Cons $h (treeIntersection $t $list2)) 
            (treeIntersection $t $list2)
         ) 
        )
    )
    )
)

; ------------------------------------

(:replaceGuardSet (-> Tree (List Tree) Tree) )
(= (replaceGuardSet NilNode $newguardSet) NilNode)
(= (replaceGuardSet (TreeNode $value $guardSet $children) $newguardSet) (TreeNode $value $newguardSet $children))

(: replaceChildren (-> Tree (List Tree) Tree))
(= (replaceChildren NilNode $newChildren) NilNode)
(= (replaceChildren (TreeNode $value $guardSet $children) $newChildren) (TreeNode $value $guardSet $newChildren))

(:replaceNodeValue (-> Tree NodeValue Tree))
(= (replaceNodeValue $tree $newValue)
    (let ($value $left $right $guardSet $children) 
        $node
        (TreeNode $newValue $left $right $new-guardSet $children)
    )
)

(:changeTree (-> Tree Tree Tree))
(= (changeTree $tree $newTree)
    (case $newTree  (
            ((TreeNode $newValue $newGuardSet $newChildren)
                $newTree
            )
            (Nil Nil)
            ($_ Error)

        )
    )
)
;; function that get the node types
(:getNodeType (-> Tree Atom))
(=(getNodeType (TreeNode (Value $value $bool $nodeType) $guardSet $children)) $nodeType)

(:compareTrees (-> Tree Tree Bool))
(=(compareTrees $fstTree $sndTree)
  (if (nodeEquality $fstTree $sndTree) True False)
)

(:compareAndRemoveNode (-> Tree (List Tree) (List Tree) (List Tree)))
(=(compareAndRemoveNode $tree Nil $accumulator) $accumulator)
(=(compareAndRemoveNode $tree (Cons $x $xs) $accumulator)
  (if (compareTrees $tree $x)
    (compareAndRemoveNode $tree $xs $accumulator)
    (compareAndRemoveNode $tree $xs (extend $accumulator (Cons $x Nil)))
  )
)

(= (treeFoldl $func $acc NilNode) $acc)
(= (treeFoldl $func $acc (TreeNode $nodeVal $leftTree $rightTree $guardSet $children))
  (case $nodeVal
    (
      ( (Value $val $truthVal LITERAL) 
        ($func $acc $val)
      )
      ( (Value $val $truthVal ROOT)
        (treeFoldl $func $acc $rightTree)
      )
      ( (Value $val $truthVal NOT)
        (treeFoldl $func $acc $rightTree)
      )
      ( (Value $val $truthVal AND)
        (treeFoldl $func (treeFoldl $func $acc $leftTree) $rightTree)
      )
      ( (Value $val $truthVal OR)
        (treeFoldl $func (treeFoldl $func $acc $leftTree) $rightTree)
      )
    )
  )
)

(= (treeFoldr $func $acc NilNode) $acc)
(= (treeFoldr $func $acc (TreeNode $nodeVal $leftTree $rightTree $guardSet $children))
  (case $nodeVal
    (
      ( (Value $val $truthVal LITERAL) ($func $acc $val) )
      ( (Value $val $truthVal ROOT) (treeFoldl $func $acc $rightTree) )
      ( (Value $val $truthVal NOT) (treeFoldl $func $acc $rightTree) )
      ( (Value $val $truthVal AND)
        (treeFoldl $func (treeFoldl $func $acc $leftTree) $rightTree)
      )
      ( (Value $val $truthVal OR)
        (treeFoldl $func (treeFoldl $func $acc $leftTree) $rightTree)
      )
    )
  )
)

; ------ Update GrandChild guardset with the difference between the current guardset(list of trees) and the given list of trees
(: computeGrandchildGuardset (-> Tree (List Tree) Tree))
(= (computeGrandchildGuardset NilNode $resultSet) NilNode)
(= (computeGrandchildGuardset (TreeNode $nodeValue $guardSet $children) $resultSet)
  (TreeNode $nodeValue (setDifference $guardSet $resultSet Nil) $children)
)

; A function that detect consistency(value match and constrient difference) between a single tree and list of tree
(: detectConsistency (-> Tree (List Tree) Bool))
(= (detectConsistency $tree Nil) True)
(= (detectConsistency 
    (TreeNode (Value $fstValue $fstConstraint $fstNodetype) $fstGuardSet $fstChildren)
    (Cons (TreeNode (Value $sndValue $sndConstraint $sndNodetype) $sndGuardSet $sndChildren) $restOfTree)
   )

  (if 
    (and 
      (== $fstValue $sndValue) 
      (not (== $fstConstraint $sndConstraint))
    )
      False
      (detectConsistency 
        (TreeNode (Value $fstValue $fstConstraint $fstNodetype) $fstGuardSet $fstChildren) 
        $restOfTree
      )
  )
)

; A function check the consistency of a tree list 
(: isConsistent (-> (List Tree) Bool))
(= (isConsistent Nil) True)
(= (isConsistent (Cons $x $xs))
  (if (detectConsistency $x $xs)
    (isConsistent $xs)
    False
  )
)

(: allExceptTargetType (-> (List Tree) NodeType (List Tree)))
(= (allExceptTargetType Nil $nodeType) Nil)
(= (allExceptTargetType $treeList $nodeType) 
  (let  
    (Cons $tree $rest) 
    $treeList 
    (unify 
      $tree  
      (TreeNode (Value $value $truthValue $nodeType) $guardSet $children)
      (allExceptTargetType $rest $nodeType)
      (Cons $tree (allExceptTargetType $rest $nodeType))
    )
  )
)



; below are helper functions for DELETE AND and OR subtree handlers
(: delete_AND_SubTree (-> Tree Tree) )
(= (delete_AND_SubTree Nil) Nil )
(= (delete_AND_SubTree $tree) 
  (let 
    (TreeNode $nodeValue $guardSet $children) $tree
    (TreeNode $nodeValue $guardSet (allExceptTargetType $children AND))
  )
)

(: delete_OR_SubTree (-> Tree Tree) )
(= (delete_OR_SubTree Nil) Nil )
(= (delete_OR_SubTree $tree) 
  (let 
    (TreeNode $nodeValue $guardSet $children) $tree
    (TreeNode $nodeValue $guardSet (allExceptTargetType $children OR))
  )
)

