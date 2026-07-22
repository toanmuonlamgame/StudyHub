import { CheckCircle2, XCircle } from 'lucide-react';

export function Feedback({ message, error }: { message: string; error?: boolean }) {
  return <div className={`feedback ${error ? 'feedback-error' : 'feedback-success'}`} role="status">
    {error ? <XCircle /> : <CheckCircle2 />}{message}
  </div>;
}
