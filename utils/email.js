import {Resend} from 'resend';

async function sendEmail(code) {
  try {
    const resend = new Resend(process.env.RESEND_API_KEY);
    const { data, error } = await resend.emails.send({
      from: 'onboarding@resend.dev',
      to: 'yvesdylane24@gmail.com',
      subject: 'Verify your account',
      html: `<p>Your verification code is <b>${code}</b></p>`,
    });

    if (error) {
      console.error('Email send error:', error);
    } else {
      console.log('Email sent successfully:', data);
    }
  } catch (err) {
    console.error('Unexpected error:', err);
  }
}

export default sendEmail;
