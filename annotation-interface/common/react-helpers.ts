import { EffectCallback, useEffect } from 'react';

/* eslint-disable react-hooks/exhaustive-deps */
/* see comments on https://stackoverflow.com/a/56767883
 * to see why the lint ignore is needed */
export const useMountEffect = (callback: EffectCallback): void =>
    useEffect(callback, []);
