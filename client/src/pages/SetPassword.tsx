import { useState } from "react";
import { useLocation } from "wouter";
import { useMutation } from "@tanstack/react-query";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Navbar } from "@/components/Navbar";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/useAuth";
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form";
import { Loader2, Eye, EyeOff, Lock } from "lucide-react";
import { apiRequest } from "@/lib/queryClient";

const setPasswordSchema = z.object({
    password: z
        .string()
        .min(8, "Password must be at least 8 characters")
        .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
        .regex(/[a-z]/, "Password must contain at least one lowercase letter")
        .regex(/[0-9]/, "Password must contain at least one number"),
    confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
    message: "Passwords don't match",
    path: ["confirmPassword"],
});

type SetPasswordForm = z.infer<typeof setPasswordSchema>;

export default function SetPassword() {
    const [, setLocation] = useLocation();
    const { toast } = useToast();
    const { user } = useAuth();
    const [showPassword, setShowPassword] = useState(false);

    const form = useForm<SetPasswordForm>({
        resolver: zodResolver(setPasswordSchema),
        defaultValues: {
            password: "",
            confirmPassword: "",
        },
    });

    const setPasswordMutation = useMutation({
        mutationFn: async (data: { password: string }) => {
            return apiRequest("/api/auth/set-password", {
                method: "POST",
                body: JSON.stringify({ password: data.password }),
            });
        },
        onSuccess: () => {
            toast({
                title: "Password set!",
                description: "Your password has been set successfully.",
            });
            // Redirect to dashboard after successful password set
            setTimeout(() => {
                setLocation("/dashboard");
            }, 1000);
        },
        onError: (error: any) => {
            toast({
                title: "Failed to set password",
                description: error.message || "Please try again.",
                variant: "destructive",
            });
        },
    });

    const onSubmit = (data: SetPasswordForm) => {
        setPasswordMutation.mutate({ password: data.password });
    };

    // Show loading while auth is checking
    if (!user) {
        return (
            <div className="min-h-screen bg-white flex items-center justify-center">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-white">
            <Navbar />

            <section className="py-20 lg:py-32 px-6 lg:px-8">
                <div className="max-w-lg mx-auto">
                    <div className="text-center space-y-4 mb-8">
                        <div className="w-16 h-16 mx-auto rounded-full bg-primary/10 flex items-center justify-center">
                            <Lock className="w-8 h-8 text-primary" />
                        </div>
                        <h1 className="text-3xl lg:text-4xl font-bold text-slate-900">
                            Set Your Password
                        </h1>
                        <p className="text-lg text-slate-600">
                            Welcome, {user.firstName}! Create a secure password to complete your account setup.
                        </p>
                    </div>

                    <div className="bg-slate-50 rounded-2xl p-8">
                        <Form {...form}>
                            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                                <FormField
                                    control={form.control}
                                    name="password"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Password</FormLabel>
                                            <FormControl>
                                                <div className="relative">
                                                    <Input
                                                        type={showPassword ? "text" : "password"}
                                                        placeholder="Create a strong password"
                                                        {...field}
                                                        data-testid="input-password"
                                                    />
                                                    <button
                                                        type="button"
                                                        className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                                                        onClick={() => setShowPassword(!showPassword)}
                                                        data-testid="button-toggle-password"
                                                    >
                                                        {showPassword ? (
                                                            <EyeOff className="w-4 h-4" />
                                                        ) : (
                                                            <Eye className="w-4 h-4" />
                                                        )}
                                                    </button>
                                                </div>
                                            </FormControl>
                                            <FormMessage />
                                            <p className="text-xs text-slate-500 mt-1">
                                                At least 8 characters with uppercase, lowercase, and number
                                            </p>
                                        </FormItem>
                                    )}
                                />

                                <FormField
                                    control={form.control}
                                    name="confirmPassword"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Confirm password</FormLabel>
                                            <FormControl>
                                                <Input
                                                    type={showPassword ? "text" : "password"}
                                                    placeholder="Confirm your password"
                                                    {...field}
                                                    data-testid="input-confirm-password"
                                                />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />

                                <Button
                                    type="submit"
                                    size="lg"
                                    className="w-full bg-primary hover:bg-primary/90 text-white font-semibold py-6"
                                    disabled={setPasswordMutation.isPending}
                                    data-testid="button-set-password"
                                >
                                    {setPasswordMutation.isPending ? (
                                        <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                                    ) : null}
                                    Set Password & Continue
                                </Button>
                            </form>
                        </Form>
                    </div>

                    <p className="text-center text-sm text-slate-500 mt-6">
                        You'll use this password to log in next time
                    </p>
                </div>
            </section>
        </div>
    );
}
