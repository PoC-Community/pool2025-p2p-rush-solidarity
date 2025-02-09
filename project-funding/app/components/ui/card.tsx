import * as React from "react"
import { cn } from "@/lib/utils"

const Card = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
    ({ className, ...props }, ref) => (
        <div 
            ref={ref} 
            className={cn(
                "w-full max-w-md mx-auto bg-white rounded-xl shadow-lg p-6 space-y-4 border border-gray-200 text-slate-700", 
                className
            )} 
            {...props} 
        />
    )
)
Card.displayName = "Card"

const CardHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
    ({ className, ...props }, ref) => (
        <div 
            ref={ref} 
            className={cn("text-center mb-4", className)} 
            {...props} 
        />
    )
)
CardHeader.displayName = "CardHeader"

const CardTitle = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLHeadingElement>>(
    ({ className, ...props }, ref) => (
        <h3 
            ref={ref} 
            className={cn("text-2xl font-bold text-slate-900", className)} 
            {...props} 
        />
    )
)
CardTitle.displayName = "CardTitle"

const CardContent = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
    ({ className, ...props }, ref) => (
        <div 
            ref={ref} 
            className={cn("space-y-3", className)} 
            {...props} 
        />
    )
)
CardContent.displayName = "CardContent"

export { Card, CardHeader, CardTitle, CardContent }