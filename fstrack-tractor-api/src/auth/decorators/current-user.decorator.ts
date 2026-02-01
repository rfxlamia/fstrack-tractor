import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Request } from 'express';

type AuthenticatedRequest = Request & {
  user: {
    id: number;
    username?: string;
    roleId?: string;
    plantationGroupId?: string | null;
  };
};

export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest<AuthenticatedRequest>();
    return request.user;
  },
);
