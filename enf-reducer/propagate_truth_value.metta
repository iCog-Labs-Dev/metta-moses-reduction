!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:list)
!(import! &self metta-moses-reduction:utilities:helper-functions)
(=(propagateTruthValue $tree $truthValueArg)
    (case $tree (
            ((TreeNode (Value $valueName $truthValue $nodeType) $right $left $guardSet $children)
                (if (== $nodeType ROOT)
                        (if (not (== $right NilNode))
                            (propagateTruthValue $right $truthValueArg)
                            $right
                        )
                        (if (== $nodeType NOT)
                            (case $right (
                                    ((TreeNode $valueChild $rightChild $leftForChild $guardSetForChild $childrenForChild)
                                        (propagateTruthValue $right (not $truthValueArg))
                                    )
                                )
                            )
                            (if (or (== $nodeType OR) (== $nodeType AND))
                                (if (== False $truthValue)
                                    (if (== $nodeType AND)
                                        (changeTree $tree (TreeNode (Value $valueName $truthValue OR) $right $left $guardSet $children))
                                        (changeTree $tree (TreeNode (Value $valueName $truthValue AND) $right $left $guardSet $children))
                                    ) 
                                    (if (and (not (== $left NilNode)) (not (== $right NilNode)))
                                        (changeTree $tree (TreeNode (Value $valueName $truthValue $truthValue) (propagateTruthValue $right $truthValueArg) (propagateTruthValue $left $truthValueArg) $guardSet $children))
                                        $tree
                                    )
                                )
                                (changeTree $tree (TreeNode (Value $valueName $truthValueArg $nodeType) $right $left $guardSet $children))

                            )

                        )

                )
            )
            (NilNode NilNode)

        )
    )

)
!(propagateTruthValue (buildTree (OR a (AND b c))) True)